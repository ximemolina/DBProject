const btnSalir = document.getElementById("btnSalir");
const btnConsultarMes = document.getElementById("btnConsultarMes");
const btnConsultarSemana = document.getElementById("btnConsultarSemana");
const btnRegresarAdmin = document.getElementById("btnRegresarAdmin");

const raw = localStorage.getItem('user');
const parsedUser = JSON.parse(raw);
const username = parsedUser.username;
const ipAdress = parsedUser.IP;

btnSalir.addEventListener("click", regresarLogin);
btnConsultarMes.addEventListener("click", consultarMes);
btnConsultarSemana.addEventListener("click", consultarSemana);
btnRegresarAdmin.addEventListener("click", regresarAdmin);

window.addEventListener('DOMContentLoaded', () => {
    revisarTipoUsuario();
  });

//Regresa a la pagina del login
async function regresarLogin() {
    try {
        const response = await fetch('/general/logout', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({ username, ipAdress })
        });
        localStorage.clear();
        const data = await response.json();
        window.location.href = 'http://localhost:3300/'; // Redirige a la nueva página
    } catch (error) {
        console.error('Error:', error);
    }
}

//Revisa si el usuario en la pagina es admin o empleado
function revisarTipoUsuario(){

    //Extraer el tipoUser del local storage
    let storedData = localStorage.getItem('user');
    let parsedData = JSON.parse(storedData);
    let tipoUser = parsedData.Tipo;

    //Boton 'desaparece' si usuario no es admin
    if (tipoUser == 'Empleado' ){
        btnRegresarAdmin.classList.add('hidden');
    }
}

//Devolverse a pagina de admin
async function regresarAdmin(){
    try {
        const response = await fetch('/empleado/regresarAdmin', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({ username, ipAdress })
        });
        window.location.href = 'http://localhost:3300/principalAdmin/ventanaPrincipalAdmin';
    } catch (error) {
        console.error('Error:', error);
    }
}

//Desplegar pagina de consulta planilla mensual
async function consultarMes(){
    window.location.href = 'http://localhost:3300/empleado/ventanaMes';    
}

//Desplegar pagina de consulta planilla semanal
async function consultarSemana(){
    window.location.href = 'http://localhost:3300/empleado/ventanaSemana'; 
}