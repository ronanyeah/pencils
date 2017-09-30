const Elm = require("./Main.elm");

const app = Elm.Main.fullscreen();

app.ports.touch.subscribe(([x, y]) => {
  const pointElem = document.elementFromPoint(x, y);
  if (!pointElem) return;

  const currElem = pointElem.closest("svg");
  if (!currElem) return;

  const id = Number(currElem.id);
  if (isNaN(id)) return;

  return app.ports.zip.send(id);
});
