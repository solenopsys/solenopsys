Bun.serve({
    fetch(req) {
      const url = new URL(req.url);
      
      if (url.pathname === "/") {
        return new Response(Bun.file("./static/index.html"), {
          headers: { "Content-Type": "text/html" },
        });
      } 
      
      if (url.pathname === "/index.js") {
        return new Response(Bun.file("./static/index.js"), {
          headers: { "Content-Type": "text/javascript" },
        });
      }
      
      if (url.pathname === "/style.css") {
        return new Response(Bun.file("./static/style.css"), {
          headers: { "Content-Type": "text/css" },
        });
      }
      
      // Default 404 response
      return new Response("404!", { status: 404 });
    },
  });
  