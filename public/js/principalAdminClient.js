const btnInsertar = document.getElementById("btnInsertar");
const btnEliminar = document.getElementById("btnEliminar");
const btnModificar = document.getElementById("btnModificar");
const btnConsultar = document.getElementById("btnConsultar");
const btnImpersonar = document.getElementById("btnImpersonar");
const btnSalir = document.getElementById("btnSalir");
const btnFiltrar = document.getElementById("btnFiltrar");

const raw = localStorage.getItem('user');
const parsedUser = JSON.parse(raw);
const username = parsedUser.username;
const ipAdress = parsedUser.IP;

btnInsertar.addEventListener("click", insertar);
btnEliminar.addEventListener("click", eliminar);
btnModificar.addEventListener("click", modificar);
btnImpersonar.addEventListener("click", impersonarEmpleado);
btnSalir.addEventListener("click", regresarLogin);
btnFiltrar.addEventListener("click", filtrarEmpleados);

window.addEventListener('DOMContentLoaded', () => {
    listarEmpleados();
  });

/////////////////////////// FUNCIONES PRINCIPALES ///////////////////////////
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

//Filtra la búsqueda en la tabla de empleados
async function filtrarEmpleados() {
    const busqueda = (document.getElementById("inputBuscar").value).trim();
    if (busqueda != '') {
        listarEmpleadosNombre(busqueda);
    }
    else {
        listarEmpleados();
    }
    
}

//Inserta un nuevo empleado*****************************
function insertar(){
    try {
        window.location.href = 'http://localhost:3300/insertarEmpleado/ventanaInsertar'; // Redirige a la nueva página
    } catch (error) {
        console.error('Error:', error);
    }
}

//Conseguir el documento de identidad del empleado para poder desplegarlo en alerta de eliminar
async function getDocumentoIdentidad(nombre){
    try {
        const response = await fetch('/principal/getDocId', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({ nombre})
          });
      
          const data = await response.json();
          resultado = data.resultado[0].ValorDocumentoIdentidad;
          return resultado;
    } catch (error) {
        alert('Error fetching IP: ' + error);
    }    

}

//Elimina el empleado seleccionado
async function eliminar(){

    const empleado = localStorage.getItem('empleado');
    if (empleado) {
        const parsedEmpleado = JSON.parse(empleado);
        const nombre = parsedEmpleado.nombre;

        try {
            const response = await fetch('/modificarEmpleado/datosEmpleado', {
                method: 'POST',
                headers: {
                'Content-Type': 'application/json'
                },
                body: JSON.stringify({ nombre })
            });
            const data = await response.json();
            const tipoDocId = data.datos.TipoDocId;
            const docId = data.datos.DocId;
            const puesto = data.datos.Puesto;
            const departamento = data.datos.Departamento;

            let respuesta = window.confirm('Nombre: '
                                        + nombre 
                                        + '\n'
                                        + tipoDocId
                                        + ': '
                                        + docId
                                        + '\nPuesto: '
                                        + puesto
                                        + '\nDepartamento: '
                                        + departamento 
                                        +'\n¿Está seguro de eliminar este empleado?');
            if (respuesta === true) {
                eliminarAfirmado(username,ipAdress,docId,nombre); 
            } else { 
                /*eliminarCancelado(username,ipAdress,nombreEmpleado);*/
                window.alert(`Se ha cancelado la eliminación del empleado ${nombre}`);
            }
        } catch (error) {
        console.log("No se pudo hacer consulta", error);
        }
    } else {
        window.alert("Debe seleccionar a un empleado");
    }
}

//Modifica datos del empleado
function modificar(){
    const empleado = localStorage.getItem('empleado');
    if (empleado) {
        try {
            window.location.href = 'http://localhost:3300/modificarEmpleado/ventanaModificar'; // Redirige a la nueva página
        } catch (error) {
            console.error('Error:', error);
        }
    }
    else {
        window.alert("Debe seleccionar a un empleado");
    }
}

function impersonarEmpleado() {
    window.location.href = 'http://localhost:3300/empleado/ventanaPrincipalEmpleado'; 
}

/////////////////////////// FUNCIONES AUXILIARES ///////////////////////////
//Carga la tabla filtrada por nombre
async function listarEmpleadosNombre(input) {
    try {
        const response = await fetch('/principalAdmin/listarEmpleadosNombre', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ input, username, ipAdress })
        });
        const data = await response.json();
        const outResultCode = data.outResultCode;
        if (outResultCode == 0) {
            const tablaHTML = data.tableHTML;
            document.getElementById("tablaEmpleados").innerHTML = tablaHTML; // Insertar en el HTML

            assignEvtCheckbox();
        }
        else {
            console.log(outResultCode, "Nombre no alfabetico");
            listarEmpleados();
        }
    } 
    catch (error) {
        console.error("Error al obtener empleados:", error);
    } 
}

//Carga la tabla a la vista
async function listarEmpleados() {
    try {
        const response = await fetch('/principalAdmin/listarEmpleados');
        const tablaHTML = await response.text();
        document.getElementById("tablaEmpleados").innerHTML = tablaHTML; // Insertar en el HTML

        assignEvtCheckbox();
    } 
    catch (error) {
        console.error("Error al obtener empleados:", error);
    }   
}

//Restringe a que solo 1 checkbox este seleccionado
function assignEvtCheckbox() {
    document.querySelectorAll(".fila-checkbox").forEach(checkbox => {
        checkbox.addEventListener("change", function() {
            document.querySelectorAll(".fila-checkbox").forEach(cb => {
                if (cb !== this) {
                    cb.checked = false; // Desmarca los otros checkboxes
                }
            });
            let empleadoSeleccionado = obtenerFilaSeleccionada();
            if (empleadoSeleccionado) {
                localStorage.setItem('empleado', JSON.stringify({nombre: empleadoSeleccionado[0]}));
            }
            console.log("Local storage", localStorage.getItem('empleado'));
            return empleadoSeleccionado;
        });
    });
}

// Devuelve el nombre del empleado que ha sido seleccionado de la tabla
function obtenerFilaSeleccionada() {
    // Buscar el checkbox que está marcado
    const checkboxSeleccionado = document.querySelector(".fila-checkbox:checked");
    
    if (checkboxSeleccionado) {
        // Obtener la fila (`tr`) que contiene el checkbox
        const fila = checkboxSeleccionado.closest("tr");

        // Extraer los valores de las celdas (`td`)
        const datosFila = Array.from(fila.children).map(td => td.textContent.trim());

        console.log("Fila seleccionada:", datosFila);
        return datosFila; // Devuelve los datos de la fila en forma de array
    } else {
        localStorage.removeItem('empleado');
        console.log("No hay ninguna fila seleccionada.");
        return null;
    }
}

//Modificar atributo 'EsActivo' del empleado en la BD por 0 para eliminarlo
async function eliminarAfirmado(username,IpAdress,docId,nombre){
    try {
        const response = await fetch('/eliminarEmpleado/eliminarEmpleado', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({docId,username,IpAdress})
            });
          
        const data = await response.json();
        alert(`El empleado ${nombre} ha sido eliminado`);
        listarEmpleados();
    } catch (error) {
        alert('Error calling SP: ' + error);
    }

}

//Añadir evento a tabla evento
async function eliminarCancelado(username,IpAdress,nombre){
    try {
        const response = await fetch('/principal/cancelEliminar', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({nombre,username,IpAdress})
            });
          
        const data = await response.json();
        window.alert('Eliminación cancelada');
    } catch (error) {
        alert('Error calling SP: ' + error);
    }
}