// See all configuration options: https://remotion.dev/docs/config
// Each option also is available as a CLI flag: https://remotion.dev/docs/cli

// Note: When using the Node.JS APIs, the config file doesn't apply. Instead, pass options directly to the APIs

import { Config } from "@remotion/cli/config";

Config.setVideoImageFormat("jpeg");
Config.setOverwriteOutput(true);
Config.setPublicDir("static/music");
Config.setEntryPoint("src/components/root/index.ts");

Config.overrideWebpackConfig((currentConfiguration) => {
  return {
    ...currentConfiguration,
    resolve: {
      ...currentConfiguration.resolve,
      fallback: {
        path: false,
        fs: false,
        util: false,
        vm: false,
        url: false,
        https: false,
        http: false,
        zlib: false,
        stream: false,
        crypto: false,
        os: false,
        buffer: false,
        assert: false,
        constants: false,
        querystring: false,
        events: false,
        child_process: false,
        cluster: false,
        dgram: false,
        dns: false,
        net: false,
        readline: false,
        repl: false,
        tls: false,
        tty: false,
      },
    },
  };
});
