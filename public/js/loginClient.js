const btnLogin = document.getElementById("btnLogin");

btnLogin.addEventListener("click", login);

window.addEventListener('DOMContentLoaded', () => {
    revisarBloqueo();
  });


//Consigue el IpAdress del usuario
async function fetchIp(){
    try {
        const response = await fetch('/login/getIp');
        const data = await response.text();
        return data;
    } catch (error) {
        alert('Error fetching IP: ' + error);
    }
}

//Revisa el ipAdress y la cantidad de logins fallidos
async function revisarBloqueo(){

    const ipAdress = await fetchIp();
    const response = await fetch('/login/revBloqueo', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ipAdress })
      });
  
      const data = await response.json();
      resultado = data.resultado[0][""];
      if(resultado >= 1) {
        btnLogin.disabled = true;
      }
}

//Muestra descripcion de error
async function mostrarError(codigo){
    const response = await fetch('/general/getError', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ codigo })
      });
  
      const data = await response.json();
      resultado = data.resultado[0].Descripcion;
      alert(resultado);
}

//Pasa a pagina principal
async function loginCorrecto(){
    console.log('Login exitoso');
    try {
        window.location.href = 'http://localhost:3300/principal/ventanaPrincipal'; // Redirige a la nueva página
    } catch (error) {
        console.error('Error:', error);
    }
}

//Revisa codigo que retorna el SP y decide que accion realizar
function revCodigo(codigo) {
    switch (codigo) {

        case 0: //Datos ingresados correctamente
            loginCorrecto();
            break;

        case 50001: //Username no existe
            mostrarError(50001);
            break;

        case 50002: //Contraseña no coincide con el username
            mostrarError(50002);
            break;

        case 50003: //Max cantidad de intentos de login fallidos sobrepasada
            btnLogin.disabled = true;
            mostrarError(50003);
            break;

        case 50008: //Error en la base de datos
            mostrarError(50008);
            break;

    }
}

//Revisa los datos que ingresó el usuario a las casillas y verifica si el usuario ya está en la base de datos
async function login(){

    const username = document.getElementById("username").value;
    const password = document.getElementById("password").value;

    try {
        
        const ipAdress = await fetchIp();
        const data = {username: username, IP: ipAdress};

        localStorage.setItem('user', JSON.stringify(data));
        fetch('/login/revLogin', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ username, password, ipAdress })
        })
        .then(response => response.json())
        .then(data => {
            revCodigo(data.resultado)
        })
        .catch(error => {
            console.error("Error parsing response:", error);
        })
    } catch (error) {
        alert("Login error: " + error.message);
    }

}