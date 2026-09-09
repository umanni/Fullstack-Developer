import serve from "@inertiajs/react/server"
import { createInertiaApp } from "@inertiajs/react"
import { renderToString } from "react-dom/server"

const pages = import.meta.glob("../pages/**/*.jsx", { eager: true })

function resolve(name) {
  const page = pages[`../pages/${name}.jsx`]
  if (!page) throw new Error(`Unknown Inertia page: ${name}`)
  return page.default
}

// No `page` here: returns a (page, renderToString) => { head, body } renderer.
const render = await createInertiaApp({ resolve })

serve(
  (page) => render(page, renderToString),
  Number(process.env.PORT || 13714),
)
