# The search is `ILIKE '%term%'` over two columns, which no ordinary B-tree
# index can serve: a leading wildcard has nothing to seek on, so PostgreSQL
# reads every row. Trigram indexes do serve it, but one per column is worse
# than none here -- the planner compares two GIN scans against one sequential
# scan and picks the sequential scan.
#
# So the two columns become one: a stored generated column that PostgreSQL
# keeps in step with them, and a single trigram index over it.
#
# Built concurrently, and therefore outside a transaction, so a deploy against
# a table with real volume in it does not lock writes while the index is built.
class IndexTheSearchWithTrigrams < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    enable_extension "pg_trgm"

    add_column :users, :searchable_text, :virtual, type: :string,
                                                   as: "full_name || ' ' || email_address", stored: true

    add_index :users, :searchable_text, using: :gin, opclass: :gin_trgm_ops,
                                        name: "index_users_on_searchable_text_trigrams",
                                        algorithm: :concurrently
  end
end
