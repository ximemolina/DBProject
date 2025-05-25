const btnSalir = document.getElementById("btnSalir");

const raw = localStorage.getItem('user');
const parsedUser = JSON.parse(raw);
const username = parsedUser.username;
const ipAdress = parsedUser.IP;

btnSalir.addEventListener("click", regresarLogin);

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