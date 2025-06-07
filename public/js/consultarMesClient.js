const btnRegresar = document.getElementById("btnRegresar");
const tablaDeducciones = document.getElementById("contenedor-tabla");
const modal = document.getElementById("modal-contenedor");
const barra = document.getElementById("modal-barra");

let isDragging = false;
let offsetX, offsetY;

const raw = localStorage.getItem('user');
const parsedUser = JSON.parse(raw);
const username = parsedUser.username
const ipAdress = parsedUser.IP

btnRegresar.addEventListener("click", regresarMain);
//tablaDeducciones.addEventListener('click', mostrarDeducciones);


window.addEventListener('DOMContentLoaded', () => {
    listarMes();
  });


barra.addEventListener("mousedown", (e) => {
  isDragging = true;
  const rect = modal.getBoundingClientRect();
  offsetX = e.clientX - rect.left;
  offsetY = e.clientY - rect.top;
  modal.style.position = "absolute";
  modal.style.margin = "0"; // elimina el centrado por márgenes
});

document.addEventListener("mousemove", (e) => {
  if (isDragging) {
    modal.style.left = `${e.clientX - offsetX}px`;
    modal.style.top = `${e.clientY - offsetY}px`;
  }
});

document.addEventListener("mouseup", () => {
  isDragging = false;
});

function regresarMain(){
    window.location.href = 'http://localhost:3300/empleado/ventanaPrincipalEmpleado'; //volver a main empleado
}

async function listarMes(){
    const response = await fetch('/empleado/listarPlanillaMes', { 
    method: 'POST',                                                
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({username,ipAdress})
  });
  const data = await response.json();
  const contenedor = document.getElementById("contenedor-tabla");
  contenedor.innerHTML = data.tabla;

 const celdasDeducciones = contenedor.querySelectorAll('.ver-deducciones');
  celdasDeducciones.forEach(celda => {
    celda.addEventListener('click', () => {
      const idMes = celda.dataset.idmes;
      mostrarDeducciones(idMes);
    }); 
  }); 
}

async function mostrarDeducciones(idMes){
    const response = await fetch('/empleado/desplegarDeducciones', { 
    method: 'POST',                                                
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({username,idMes})
  });
  const data = await response.json();
  const modal = document.getElementById("modal-deducciones");
  const modalContenedor = document.getElementById("modal-contenedor");

  document.getElementById("contenido-modal").innerHTML = data.tabla;
  modal.classList.remove("hidden");

  // Centrar modal con posición absoluta
  modalContenedor.style.left = `calc(50% - ${modalContenedor.offsetWidth / 2}px)`;
  modalContenedor.style.top = `calc(50% - ${modalContenedor.offsetHeight / 2}px)`;
}
document.getElementById("cerrar-modal").addEventListener("click", () => {
  document.getElementById("modal-deducciones").classList.add("hidden");
})