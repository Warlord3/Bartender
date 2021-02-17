var connection = new WebSocket('ws://' + window.location.hostname + ':81/', ['arduino']);
connection.onopen = function () {
  connection.send('Connect ' + new Date());
};
connection.onerror = function (error) {
  console.log('WebSocket Error ', error);
};
connection.onmessage = function (e) {
  console.log('Server: ', e.data);
};
connection.onclose = function () {
  console.log('WebSocket connection closed');
};

function startPump(ID, Milliliter) {
  var code = "pump" + ID + "1" + Milliliter;
  connection.send(code);
}
function stopPump(ID, Milliliter) {
  var code = "pump" + ID + "0" + Milliliter;
  connection.send(code);
}
function startSingle(ID) {
  var code = "test" + ID + "1"
  connection.send(code);
}
function stopSingle(ID) {
  var code = "test" + ID + "0"
  connection.send(code);
}

function saveConfig() {
  var data = [];
  data[0] = document.getElementById('Pump1').value;
  data[1] = document.getElementById('Pump2').value;
  data[2] = document.getElementById('Pump3').value;
  data[3] = document.getElementById('Pump4').value;
  data[4] = document.getElementById('Pump5').value;
  data[5] = document.getElementById('Pump6').value;
  data[6] = document.getElementById('Pump7').value;
  data[7] = document.getElementById('Pump8').value;
  connection.send("config" + data);
}

function sendDrink() {
  var code = "pump" + ID + "1" + Milliliter;
  connection.send(code);
}

function openSlideMenu() {
  document.getElementById('side-menu').style.width = "250px";
  document.body.style.backgroundColor = "rgba(0,0,0,0.2)";
}
function closeSlideMenu() {
  document.getElementById('side-menu').style.width = "0";
  document.body.style.backgroundColor = "white";
}

function addData() {
  var table = document.getElementById("myTable");
  var row = table.insertRow(table.rows.length);
  var cell1 = row.insertCell(0);
  var cell2 = row.insertCell(1);
  var cell3 = row.insertCell(2);
  var cell4 = row.insertCell(3);
  var cell5 = row.insertCell(4);
  var cell6 = row.insertCell(5);
  var cell7 = row.insertCell(6);
  var cell8 = row.insertCell(7);
  var cell9 = row.insertCell(8);
  cell1.innerHTML = "New Cell1";
  cell2.innerHTML = "New Cell2";
  cell3.innerHTML = "New Cell2";
  cell4.innerHTML = "New Cell2";
  cell5.innerHTML = "New Cell2";
  cell6.innerHTML = "New Cell2";
  cell7.innerHTML = "New Cell2";
  cell8.innerHTML = "New Cell2";
  cell9.innerHTML = "New Cell2";
}

function updateDrinks() {
  $.getJSON("beverages.json", function (json) {
    console.log("JSON Data received, name is " + json[0].hersteller);
    var select = document.getElementById("Settings");
    for (var i = 0; i < select.getElementsByClassName("drinkSelect").length; i++) {
      var test = select.getElementsByClassName("drinkSelect")[i];
      for (var j = 0; j < json.length; j++) {
        var option = document.createElement('option');
        option.text = (j + 1) + ". " + json[j].name + " - " + json[j].hersteller;
        option.value = j;
        test.add(option);
      }
    }
  });
}
function onInput(e) {
  var input = document.getElementsByClassName(e.className);
  var divInput = input[0].parentElement;
  var divlevel = divInput.parentElement;
  console.log(divlevel.className);
}