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

window.addEventListener('DOMContentLoaded', () => {
    listarSemana();
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

async function listarSemana(){
    const response = await fetch('/empleado/listarPlanillaSemana', { 
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
      const idSemana = celda.dataset.idsemana;

      mostrarDeducciones(idSemana);
    }); 
  }); 

 const celdasSalario = contenedor.querySelectorAll('.ver-semana');
  celdasSalario.forEach(celda => {
    celda.addEventListener('click', () => {
      const idSemana = celda.dataset.idsemana;

      mostrarSalario(idSemana);
    }); 
  }); 
}

async function mostrarDeducciones(idSemana){
    const response = await fetch('/empleado/desplegarDeduccionesSemana', { 
    method: 'POST',                                                
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({username,idSemana})
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

async function mostrarSalario(idSemana){
    const response = await fetch('/empleado/desplegarSalario', { 
    method: 'POST',                                                
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({username,idSemana})
  });

  const data = await response.json();
  const modal = document.getElementById("modal-deducciones");
  const modalContenedor = document.getElementById("modal-contenedor");
console.error("revisado3")
  document.getElementById("contenido-modal").innerHTML = data.tabla;
  modal.classList.remove("hidden");

  // Centrar modal con posición absoluta
  modalContenedor.style.left = `calc(50% - ${modalContenedor.offsetWidth / 2}px)`;
  modalContenedor.style.top = `calc(50% - ${modalContenedor.offsetHeight / 2}px)`;
}
document.getElementById("cerrar-modal").addEventListener("click", () => {
  document.getElementById("modal-deducciones").classList.add("hidden");
})
