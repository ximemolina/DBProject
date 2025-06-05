const btnRegresar = document.getElementById("btnRegresar");

btnRegresar.addEventListener("click", regresarMain);

function regresarMain(){
    window.location.href = 'http://localhost:3300/empleado/ventanaPrincipalEmpleado'; //volver a main empleado
}