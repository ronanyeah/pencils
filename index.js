var Elm = require("./Main.elm");

var app = Elm.Main.fullscreen();

app.ports.touchPort.subscribe((e, open) => {
  const touch = e.touches;

  const x = touch ? touch[0].pageX : e.pageX;

  const y = touch ? touch[0].pageY : e.pageY;

  const pointElem = document.elementFromPoint(x, y);
  if (!pointElem) return;

  const currElem = pointElem.closest("svg");
  if (!currElem) return;

  console.log(currElem.id);
});
