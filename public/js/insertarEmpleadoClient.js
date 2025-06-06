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

const raw = localStorage.getItem('user');
const parsedUser = JSON.parse(raw);
const username = parsedUser.username;
const ipAdress = parsedUser.IP;

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
        const nombreActual = nombre;
        const nuevoNombre = (NombreNuevo.value).trim();
        const nuevoTipoDocId = SeleccionTipoDocId.textContent;
        const nuevoDocId = (DocumentoIdentidadNuevo.value).trim();
        const nuevaFechaNac = (NuevaFechaNacimiento.value).trim();
        const nuevoPuesto = SeleccionPuesto.textContent;
        const nuevoDepartamento = SeleccionDepartamento.textContent;
        console.log('fecha', nuevaFechaNac);
        if (nuevoNombre != "" && nuevoDocId != "") {
            const response = await fetch('/modificarEmpleado/modificarEmpleado', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({ nombreActual, nuevoNombre, nuevoTipoDocId, nuevoDocId,
                                nuevaFechaNac, nuevoPuesto, nuevoDepartamento, username, 
                                ipAdress })
            });

            const data = await response.json();
            const code = data.outResultCode;
            console.log('Codigo resultado: ', code);

            if (code > 0) {
                descripcionError(code);
            }
            else {
                alert('Los datos del empleado han sido modificados exitosamente');

                regresarPrincipal();
            }
        }
        else {
            window.alert('Debe llenar todos los espacions');
        }
        
    } catch (error) {
        console.log("No se pudo hacer modificacion", error);
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
    document.querySelectorAll('#DropdownTipoDocId a').forEach(item => {
        item.addEventListener('click', (event) => {
          event.preventDefault(); // Evita que el enlace recargue la página
          const valorSeleccionado = event.target.textContent.trim(); // Obtiene el texto del elemento
          console.log('Tipo Doc Id seleccionado:', valorSeleccionado);
          SeleccionTipoDocId.textContent = valorSeleccionado;
          DropdownTipoDocId.classList.toggle('hidden');
        });
    });
}

//Obtener el valor seleccionado de departamento
function obtenerDepartamentoSeleccionado() {
    document.querySelectorAll('#DropdownDepartamento a').forEach(item => {
        item.addEventListener('click', (event) => {
          event.preventDefault(); // Evita que el enlace recargue la página
          const valorSeleccionado = event.target.textContent.trim(); // Obtiene el texto del elemento
          console.log('Departamento seleccionado:', valorSeleccionado);
          SeleccionDepartamento.textContent = valorSeleccionado;
          DropdownDepartamento.classList.toggle('hidden');
        });
    });
}

//Restringe la seleccion de fecha 
function maxFecha() {
    // Obtener la fecha actual en formato yyyy-mm-dd
    const hoy = new Date().toISOString().split('T')[0];

    // Establecer el atributo max al input
    NuevaFechaNacimiento.setAttribute('max', hoy);

}