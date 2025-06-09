const btnCancelar = document.getElementById("btnCancelar");
const btnInsertar = document.getElementById("btnInsertar");
const btnMenuPuesto = document.getElementById("btnMenuPuesto");
const btnMenuTipoDocId = document.getElementById("btnMenuTipoDocId");
const btnMenuDepartamento = document.getElementById("btnMenuDepartamento");
const SeleccionTipoDocId = document.getElementById("SeleccionTipoDocId");
const SeleccionPuesto = document.getElementById("SeleccionPuesto");
const SeleccionDepartamento = document.getElementById("SeleccionDepartamento");
const DropdownPuesto = document.getElementById("DropdownPuesto");
const DropdownTipoDocId = document.getElementById("DropdownTipoDocId");
const DropdownDepartamento = document.getElementById("DropdownDepartamento");
const NombreEmpleado = document.getElementById("NombreEmpleado");
const DocumentoIdentidad = document.getElementById("DocumentoIdentidad");
const FechaNacimiento = document.getElementById("FechaNacimiento");
const Usuario = document.getElementById("Usuario");
const Password = document.getElementById("Password");

const raw = localStorage.getItem('user');
const parsedUser = JSON.parse(raw);
const username = parsedUser.username;
const ipAdress = parsedUser.IP;
let idTipoDocId = 0;
let idDepartamento = 0;

btnCancelar.addEventListener('click', regresarPrincipal);
btnInsertar.addEventListener('click', insertarEmpleado);
btnMenuPuesto.addEventListener('click', () => {
    const isExpanded = btnMenuPuesto.getAttribute('aria-expanded') === 'true';
    // Alterna el atributo aria-expanded
    btnMenuPuesto.setAttribute('aria-expanded', !isExpanded);
    // Alterna la visibilidad del menú
    DropdownPuesto.classList.toggle('hidden');
});
btnMenuTipoDocId.addEventListener('click', () => {
    const isExpanded = btnMenuTipoDocId.getAttribute('aria-expanded') === 'true';
    // Alterna el atributo aria-expanded
    btnMenuTipoDocId.setAttribute('aria-expanded', !isExpanded);
    // Alterna la visibilidad del menú
    DropdownTipoDocId.classList.toggle('hidden');
});
btnMenuDepartamento.addEventListener('click', () => {
    const isExpanded = btnMenuDepartamento.getAttribute('aria-expanded') === 'true';
    // Alterna el atributo aria-expanded
    btnMenuDepartamento.setAttribute('aria-expanded', !isExpanded);
    // Alterna la visibilidad del menú
    DropdownDepartamento.classList.toggle('hidden');
});

window.addEventListener('DOMContentLoaded', () => {
    generarMenuPuesto();
    generarMenuTipoDocId();
    generarMenuDepartamento();
});

//Para regresar a la pagina principal
function regresarPrincipal() {
    try {
        window.location.href = 'http://localhost:3300/principalAdmin/ventanaPrincipalAdmin'; // Redirige a la pagina principal
    } catch (error) {
        console.error('Error:', error);
    }
}

//Inserta nuevo empleado
async function insertarEmpleado(params) {
    try {
        const nombre = (NombreEmpleado.value).trim();
        const docId = (DocumentoIdentidad.value).trim();
        const fechaNac = (FechaNacimiento.value).trim();
        const nombrePuesto = SeleccionPuesto.textContent;
        const usuario = (Usuario.value).trim();
        const password = (Password.value).trim();

        if (nombre != "" && idTipoDocId != 0 && docId != "" && fechaNac != "" 
            && nombrePuesto != "Seleccionar puesto" && idDepartamento != 0
            && usuario != "" && password != "") {
            const response = await fetch('/insertarEmpleado/insertarEmpleado', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({ nombre, idTipoDocId, docId, fechaNac, 
                                    nombrePuesto, idDepartamento, usuario, 
                                    password, username, ipAdress })
            });

            const data = await response.json();
            const code = data.outResultCode;
            console.log('Codigo resultado: ', code);

            if (code > 0) {
                descripcionError(code);
            }
            else {
                alert('Se ha incluido el nuevo empleado exitosamente');

                regresarPrincipal();
            }
        }
        else {
            window.alert('Debe llenar todos los espacions');
        }
        
    } catch (error) {
        console.log("No se pudo hacer insercion", error);
    }
}
        
//Generar el menu dropdown de puesto
async function generarMenuPuesto() {
    try {
        const response = await fetch('/modificarEmpleado/generarMenuPuesto');

        // Verifica que la respuesta sea exitosa
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();

        // Verifica si el atributo menuHTML existe en la respuesta
        if (data.menuHTML) {
            DropdownPuesto.innerHTML = data.menuHTML; // Inserta el HTML en el elemento
            obtenerPuestoSeleccionado();
        } else {
            console.error("Error: No se encontró 'menuHTML' en la respuesta:", data);
        }
    } catch (error) {
        // Manejo de errores
        console.error("No se pudo generar el menú:", error);
    }
}

//Generar el menu dropdown de tipo doc id
async function generarMenuTipoDocId() {
    try {
        const response = await fetch('/modificarEmpleado/generarMenuTipoDocId');

        // Verifica que la respuesta sea exitosa
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();

        // Verifica si el atributo menuHTML existe en la respuesta
        if (data.menuHTML) {
            DropdownTipoDocId.innerHTML = data.menuHTML; // Inserta el HTML en el elemento
            obtenerTipoDocIdSeleccionado();
        } else {
            console.error("Error: No se encontró 'menuHTML' en la respuesta:", data);
        }
    } catch (error) {
        // Manejo de errores
        console.error("No se pudo generar el menú:", error);
    }
}

//Generar el menu dropdown de departamento
async function generarMenuDepartamento() {
    try {
        const response = await fetch('/modificarEmpleado/generarMenuDepartamento');

        // Verifica que la respuesta sea exitosa
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();

        // Verifica si el atributo menuHTML existe en la respuesta
        if (data.menuHTML) {
            DropdownDepartamento.innerHTML = data.menuHTML; // Inserta el HTML en el elemento
            obtenerDepartamentoSeleccionado();
        } else {
            console.error("Error: No se encontró 'menuHTML' en la respuesta:", data);
        }
    } catch (error) {
        // Manejo de errores
        console.error("No se pudo generar el menú:", error);
    }
}

//Obtener el valor seleccionado de puesto
function obtenerPuestoSeleccionado() {
    document.querySelectorAll('#DropdownPuesto a').forEach(item => {
        item.addEventListener('click', (event) => {
          event.preventDefault(); // Evita que el enlace recargue la página
          const valorSeleccionado = event.target.textContent.trim(); // Obtiene el texto del elemento
          console.log('Puesto seleccionado:', valorSeleccionado);
          SeleccionPuesto.textContent = valorSeleccionado;
          DropdownPuesto.classList.toggle('hidden');
        });
    });
}

//Obtener el valor seleccionado de tipo doc id
function obtenerTipoDocIdSeleccionado() {
    document.querySelectorAll('#DropdownTipoDocId a').forEach((item, index) => {
        item.dataset.id = index + 1; // Asigna un número interno al elemento
        item.addEventListener('click', (event) => {
          event.preventDefault(); // Evita que el enlace recargue la página
          idTipoDocId = parseInt(event.target.dataset.id, 10);
          const valorSeleccionado = event.target.textContent.trim(); // Obtiene el texto del elemento
          console.log(`ID: ${idTipoDocId}, Nombre: ${valorSeleccionado}`);
          SeleccionTipoDocId.textContent = valorSeleccionado;
          DropdownTipoDocId.classList.toggle('hidden');
        });
    });
}

//Obtener el valor seleccionado de departamento
function obtenerDepartamentoSeleccionado() {
    const elementos = document.querySelectorAll('#DropdownDepartamento a');

    elementos.forEach((item, index) => {
        item.dataset.id = index + 1; // Asigna un número interno al elemento

        item.addEventListener('click', (event) => {
            event.preventDefault(); // Evita que el enlace recargue la página
            idDepartamento = parseInt(event.target.dataset.id, 10); // Obtiene el número asignado
            const nombreSeleccionado = event.target.textContent.trim(); // Obtiene el nombre visual
            console.log(`ID: ${idDepartamento}, Nombre: ${nombreSeleccionado}`);
            SeleccionDepartamento.textContent = nombreSeleccionado; // Muestra el nombre visualmente
            DropdownDepartamento.classList.toggle('hidden');
        });
    });
}


//Restringe la seleccion de fecha 
function maxFecha() {
    // Obtener la fecha actual en formato yyyy-mm-dd
    const hoy = new Date().toISOString().split('T')[0];

    // Establecer el atributo max al input
    FechaNacimiento.setAttribute('max', hoy);

}