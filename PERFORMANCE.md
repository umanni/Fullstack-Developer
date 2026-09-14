# Performance: Ruby 4 JIT profiling

This app can run with no JIT, with YJIT, or with ZJIT, the method-based JIT compiler that is new in Ruby 4.0. This document explains how the JIT is chosen, how `bin/jit-profile` measures the three options on this app's own code, and what the measurements say.

## Summary

- **Production runs YJIT** (`RUBY_JIT: yjit` in [config/deploy.yml](config/deploy.yml)).
- **YJIT** is **1.53× to 2.12×** faster than the interpreter on this app's hot paths.
- **ZJIT** is **1.07× to 1.20×** faster than the interpreter, which makes YJIT **1.40× to 1.83×** faster than ZJIT on Ruby 4.0.6. ZJIT also used more memory: 12.9 MB against 9.2 MB.
- **Switching is one environment variable:** `RUBY_JIT=zjit`. Re-run `bin/jit-profile` after each Ruby upgrade and switch once ZJIT is ahead.

## Choosing the JIT: `RUBY_JIT`

| `RUBY_JIT` | Effect |
|---|---|
| unset | Rails' default: YJIT outside development and test, no JIT in development and test |
| `yjit` | YJIT, in any environment |
| `zjit` | ZJIT, and Rails' YJIT switch is turned off |
| `off` | The interpreter only |

How it works ([lib/ruby_jit.rb](lib/ruby_jit.rb), [config/initializers/ruby_jit.rb](config/initializers/ruby_jit.rb)):

- **Only one JIT per process.** Ruby refuses to enable a second JIT ("Only one JIT can be enabled at the same time"). So the initializer sets `config.yjit` before Rails' own `:enable_yjit` step reads it.
- **Enabled after boot.** ZJIT is turned on in `after_initialize`, after the app has booted, the same way Rails enables YJIT. Code that only runs while booting isn't compiled.
- **Graceful fallback.** A Ruby built without ZJIT logs a warning and runs without a JIT. That includes Rubies compiled without `rustc`, such as a typical rbenv or ruby-build install. The official `ruby:4.0.6-slim` image used by the [Dockerfile](Dockerfile) has both YJIT and ZJIT.

## The profiler: `bin/jit-profile`

### What it measures

Four CPU-bound slices of this app. Each builder does its setup first (which may read the schema), and the timed loop doesn't query the database. The numbers therefore compare JIT compilers rather than Postgres round trips.

| Workload | What runs | Where it matters |
|---|---|---|
| `serialize_users` | `UserSerializer.collection` over 250 users, then `to_json` | Admin users table, shared `auth` props on every page |
| `import_rows` | 250 spreadsheet rows through `Imports::UserRow`: header aliases, cell sanitising, validation | Spreadsheet imports |
| `parse_csv` | `Imports::CsvRowSet` reading a 250-row CSV file | Spreadsheet imports |
| `render_page` | `GET /registration/new` through the whole Rack stack: middleware, routing, controller, Inertia renderer, layout | Every full page load |

### How it measures

- **One fresh process per JIT.** [lib/jit_profile/driver.rb](lib/jit_profile/driver.rb) starts `bin/rails runner` once for the interpreter, once for YJIT and once for ZJIT, because a process can never switch JITs. Each is chosen with `RUBY_JIT`, so it is enabled after boot, as in production.
- **Warmup, then a timed run.** Each workload is called in a loop for 2 seconds untimed, so the JIT can profile and compile it, then for 5 seconds that count ([lib/jit_profile/benchmark.rb](lib/jit_profile/benchmark.rb)).
- **Isolated workloads.** A full GC runs and the JIT's counters are reset before each one.
- **SSR and logging off.** `INERTIA_SSR_ENABLED=false` and `RAILS_LOG_LEVEL=warn` keep the Node round trip and log writes out of `render_page`.
- **A separate diagnostics pass.** ZJIT runs a fourth time, with `--zjit-stats-quiet --zjit-disable`. The stats counters slow compiled code down, so that pass is kept out of the timed numbers and used only for the diagnostics table.

### Running it

It needs a Ruby built with ZJIT, so run it in the Docker image. Production mode gives representative numbers: eager loading, no code reloader, quiet logs.

```bash
docker compose up -d            # once: the web container's db:prepare creates the schema
docker compose stop web         # keep the running app from competing for CPU
docker compose run --rm \
  -e RAILS_ENV=production -e RACK_ENV=production \
  -e DATABASE_URL=postgres://umanni:secret@umanni-pg/umanni_users_development \
  -e VITE_RUBY_PUBLIC_OUTPUT_DIR=vite-dev \
  web sh -c 'bin/jit-profile && cat tmp/jit-profile/results.json'
```

- `DATABASE_URL` points production mode at the development database, which already has the schema. Only `User`'s columns are read, during setup.
- `VITE_RUBY_PUBLIC_OUTPUT_DIR=vite-dev` uses the assets the image builds. The image builds with `RAILS_ENV=development`.
- The report is printed. `results.json` is printed too, because `--rm` discards the container's `tmp/`.

Options: `--warmup SECONDS`, `--duration SECONDS`, `--workloads serialize_users,render_page`, `--output DIR`. If a run doesn't get the JIT it asked for (say, ZJIT on a Ruby without it), the report opens with a warning instead of silently comparing the interpreter with itself.

## Results

Measured on 2026-09-11:
- **Machine:** Apple M1, with Docker Desktop's Linux VM given 8 CPUs and 3.8 GiB of memory.
- **Ruby:** `ruby 4.0.6 (2026-07-14 revision 03b6d3f889) +PRISM [aarch64-linux]`
- **Rails environment:** production
- **Run length:** one run, 2 s warmup and 5 s measured per workload.

### Throughput (iterations per second, higher is better)

| Workload | Interpreter | YJIT | ZJIT | YJIT vs interpreter | ZJIT vs interpreter | YJIT vs ZJIT |
|---|--:|--:|--:|--:|--:|--:|
| serialize_users | 955.5 | 2,025.4 | 1,108.4 | 2.12× | 1.16× | 1.83× |
| import_rows | 130.5 | 203.6 | 140.0 | 1.56× | 1.07× | 1.45× |
| parse_csv | 387.7 | 593.4 | 423.0 | 1.53× | 1.09× | 1.40× |
| render_page | 1,152.6 | 1,992.7 | 1,385.2 | 1.73× | 1.20× | 1.44× |

### Compilation and memory

| | YJIT | ZJIT |
|---|--:|--:|
| Methods compiled for `render_page` | 1,056 | 1,190 |
| Compile time for `render_page` | not reported | 411 ms |
| Machine code after all four workloads | 1.8 MB | 5.1 MB |
| JIT memory after all four workloads | 9.2 MB | 12.9 MB |

### ZJIT diagnostics (`--zjit-stats` pass)

| Workload | Side exits | Calls not specialised | Top side exits | Top send fallbacks |
|---|--:|--:|---|---|
| serialize_users | 9,446,740 | 32.3% | guard_shape_failure 5.3M, block_param_proxy_not_iseq_or_ifunc 2.1M, guard_type_failure 2.1M | send_no_profiles 12.6M, send_not_optimized_method_type 7.3M, send_without_block_polymorphic 2.2M |
| import_rows | 6,439,944 | 26.0% | guard_type_failure 3.7M, block_param_proxy_not_iseq_or_ifunc 1.8M, guard_shape_failure 0.8M | send_without_block_polymorphic 6.9M, one_or_more_complex_arg_pass 3.1M |
| parse_csv | 19,322,883 | 9.9% | guard_shape_failure 11.3M, guard_type_failure 8.0M | send_without_block_polymorphic 1.6M, send_no_profiles 1.1M |
| render_page | 1,897,733 | 26.2% | guard_shape_failure 0.9M, guard_type_failure 0.5M, unhandled_yarv_insn 0.2M | send_without_block_polymorphic 4.8M, one_or_more_complex_arg_pass 0.9M |

## Reading the diagnostics

**A side exit** is compiled code handing control back to the interpreter because an assumption it was compiled under no longer holds. Every exit costs a trip out of machine code and back, so millions of them explain why ZJIT stays close to the interpreter on this app:

- **`guard_shape_failure`:** code was specialised for objects with one instance-variable layout (shape), then received objects with another. ActiveModel and ActiveRecord objects, and the rows and hashes built while parsing a CSV, reach the same call sites with different shapes.
- **`guard_type_failure`:** a call site saw more than one class, for example a value that is sometimes a `String` and sometimes `nil`.
- **`block_param_proxy_not_iseq_or_ifunc`:** a block passed along as `&block` that is a `Symbol` or `Proc` object rather than a literal block, as in `tap(&:valid?)`.

**Send fallbacks** are method calls ZJIT compiled as plain dynamic dispatch instead of specialising them:

- polymorphic call sites (`send_without_block_polymorphic`)
- calls compiled before the site had profile data (`send_no_profiles`)
- method types it doesn't optimise yet (`send_not_optimized_method_type`)
- keyword and splat argument passing (`one_or_more_complex_arg_pass`)

Most of these sites are in Rails, ActiveModel and the CSV library, not in this app's code. Rewriting app code to avoid them wouldn't pay off. The practical lever is the Ruby version.

## Decision

- **Keep `RUBY_JIT=yjit` in production.** On every workload it is at least 1.4× faster than ZJIT, and it uses less memory.
- **Keep ZJIT one variable away.** `RUBY_JIT=zjit` needs no code change, and the specs cover both paths.
- **Re-run `bin/jit-profile` when Ruby is upgraded.** Switch `RUBY_JIT` in [config/deploy.yml](config/deploy.yml) once the ZJIT column overtakes YJIT, and keep an eye on the side-exit counts: they show whether ZJIT has started handling this app's patterns.

## Caveats

- **Run-to-run variation.** These numbers come from one run on a laptop's Docker VM, so expect some variation. A shorter smoke run (0.2 s warmup, 0.5 s measured) gave the same ordering on every workload.
- **CPU-bound slices, not whole requests.** Real requests also wait on Postgres, the SSR server and the network, so end-to-end gains are smaller than these numbers.
- **Slow first compile.** ZJIT's `render_page` compile time (411 ms, spread over the first requests) adds to warmup after each deploy.
