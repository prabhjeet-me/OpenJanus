// .eleventy.js
export default function (eleventyConfig) {
  const port = process.env.DEV_SERVER_PORT;

  // Server config
  eleventyConfig.setServerOptions({
    port,
  });

  // Set global permalinks to resource.html style
  eleventyConfig.addGlobalData("permalink", () => {
    return (data) =>
      `${data.page.filePathStem}.${data.page.outputFileExtension}`;
  });

  return {
    dir: {
      input: "pages", // source files
      includes: "_includes", // default, relative to input
      output: "container/html", // output directory
    },
  };
}
