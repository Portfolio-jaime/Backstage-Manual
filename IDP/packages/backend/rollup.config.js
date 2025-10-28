import { buildBackend } from '@backstage/cli';

buildBackend({
  entry: 'src/index.ts',
  outDir: 'dist',
});
