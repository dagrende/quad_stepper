var readline = require('readline');
var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

let step = 0;
rl.on('line', function(line){
  if (line[0] == '#') {
    let secs = +line.substring(1, line.indexOf(' ')) / 1000000.0;
    let turns = step / 1600.0;
    console.log('[',secs, ',', turns, '],');
    ++step;
  }
})
