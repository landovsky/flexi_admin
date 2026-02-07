import * as esbuild from 'esbuild'
import path from 'path'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const watch = process.argv.includes('--watch')

const buildOptions = {
  entryPoints: ['app/javascript/application.js'],
  bundle: true,
  sourcemap: true,
  format: 'esm',
  outdir: 'app/assets/builds',
  publicPath: '/assets',
  resolveExtensions: ['.js'],
  alias: {
    'flexi_admin': path.resolve(__dirname, '../../lib/flexi_admin/javascript/flexi_admin.js')
  }
}

if (watch) {
  const ctx = await esbuild.context(buildOptions)
  await ctx.watch()
  console.log('esbuild: watching for changes...')
} else {
  await esbuild.build(buildOptions)
}
