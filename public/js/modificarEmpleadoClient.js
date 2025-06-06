const btnCancelar = document.getElementById("btnCancelar");
const btnModificar = document.getElementById("btnModificar");
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
const NombreNuevo = document.getElementById("NombreNuevo");
const TipoDocId = document.getElementById("TipoDocId");
const DocumentoIdentidad = document.getElementById("DocumentoIdentidad");
const DocumentoIdentidadNuevo = document.getElementById("DocumentoIdentidadNuevo");
const FechaNacimiento = document.getElementById("FechaNacimiento");
const NuevaFechaNacimiento = document.getElementById("NuevaFechaNacimiento");
const Puesto = document.getElementById("Puesto");
const Departamento = document.getElementById("Departamento");

const raw = localStorage.getItem('user');
const parsedUser = JSON.parse(raw);
const username = parsedUser.username;
const ipAdress = parsedUser.IP;
const empleado = localStorage.getItem('empleado');
const parsedEmpleado = JSON.parse(empleado);
const nombre = parsedEmpleado.nombre;

btnCancelar.addEventListener('click', regresarPrincipal);
btnModificar.addEventListener('click', modificarEmpleado);
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
    mostrarEmpleado();
});

//Para regresar a la pagina principal
function regresarPrincipal() {
    try {
        localStorage.removeItem('empleado');
        window.location.href = 'http://localhost:3300/principalAdmin/ventanaPrincipalAdmin'; // Redirige a la pagina principal
    } catch (error) {
        console.error('Error:', error);
    }
}

//Muestra la info actual del empleado
async function mostrarEmpleado() {
    try {
        const response = await fetch('/modificarEmpleado/datosEmpleado', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({ nombre })
        });

        const data = await response.json();
        const fecha = new Date(data.datos.FechaNacimiento);
        // Extraer los valores correctamente
        const dia = String(fecha.getUTCDate()).padStart(2, '0');
        const mes = String(fecha.getUTCMonth() + 1).padStart(2, '0'); // Mes en JavaScript empieza en 0
        const anio = fecha.getUTCFullYear();
        const fechaFormateada = `${anio}-${mes}-${dia}`;

        NombreEmpleado.textContent = `Nombre: ${data.datos.Nombre}`;
        NombreNuevo.value = data.datos.Nombre;
        TipoDocId.textContent = `Tipo documento de identidad: ${data.datos.TipoDocId}`;
        SeleccionTipoDocId.textContent = data.datos.TipoDocId;
        DocumentoIdentidad.textContent = `Documento de identidad: ${data.datos.DocId}`;
        DocumentoIdentidadNuevo.value = data.datos.DocId;
        FechaNacimiento.textContent = `Fecha de nacimiento: ${fechaFormateada}`;
        NuevaFechaNacimiento.value = fechaFormateada;
        Puesto.textContent = `Puesto: ${data.datos.Puesto}`;
        SeleccionPuesto.textContent = data.datos.Puesto;
        Departamento.textContent = `Departamento: ${data.datos.Departamento}`;
        SeleccionDepartamento.textContent = data.datos.Departamento;
 
        generarMenuPuesto();
        generarMenuTipoDocId();
        generarMenuDepartamento();
        maxFecha();
    } catch (error) {
        console.log("No se pudo hacer consulta", error);
    }
}

//Modifica el empleado
async function modificarEmpleado(params) {
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

//Muestra descripcion de error
async function descripcionError(codigo){
    const response = await fetch('/general/getError', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ codigo })
      });
  
      const data = await response.json();
      resultado = data.resultado[0].Descripcion;
      alert('Error: ' + resultado);
}