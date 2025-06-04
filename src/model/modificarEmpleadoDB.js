import sql from 'mssql';
import { conectarDB } from "../config/database.js";

//Obtener todos los puestos
export async function listarPuestos() {
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .output('outResultCode', sql.Int)
            .execute('ListarPuestos');

        return [resultado.output.outResultCode, resultado.recordset];
    } catch (error) {
        console.error('Error ejecutando el SP ListarPuestos:', error)
    }
}

//Obtener todos los departamentos
export async function listarDepartamentos() {
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .output('outResultCode', sql.Int)
            .execute('ListarDepartamentos');

        return [resultado.output.outResultCode, resultado.recordset];
    } catch (error) {
        console.error('Error ejecutando el SP ListarDepartamentos:', error)
    }
}

//Obtener todos los tipos de documento identidad
export async function listarTiposDocId() {
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .output('outResultCode', sql.Int)
            .execute('ListarTiposDocId');

        return [resultado.output.outResultCode, resultado.recordset];
    } catch (error) {
        console.error('Error ejecutando el SP ListarTiposDocId:', error)
    }
}

//Generar menu dropdown
export function construirMenuDropdown(opciones) {
    let html = ''; // Construye las opciones como una cadena HTML

    opciones.forEach((opcion, index) => {
        html += `<a href="#" 
                  class="block px-4 py-2 text-lg text-gray-700 hover:bg-gray-100" 
                  role="menuitem" 
                  tabindex="-1" 
                  id="menu-item-${index}">
                  ${opcion}
                </a>`;
    });

    return html; // Retorna el HTML generado
}

//Pedir informacion de un empleado
export async function consultarEmpleado(nombre) {
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inNombre', sql.VarChar(64), nombre)
            .output('outResultCode', sql.Int)
            .execute('ConsultarEmpleado');

        return [resultado.output.outResultCode, resultado.recordset];
    } catch (error) {
        console.error('Error ejecutando el SP ConsultarEmpleado:', error)
    }
}

//Modificar empleado
export async function modificarEmpleado(nombreActual, nuevoNombre, nuevoTipoDocId, 
                                        nuevoDocId, nuevaFechaNac, nuevoPuesto, 
                                        nuevoDepartamento, username, ipAdress) {
  try {
          let pool = await conectarDB();
  
          let resultado = await pool.request()
              .input('inNombre', sql.VarChar(64), nombreActual)
              .input('inNuevoNombre', sql.VarChar(64), nuevoNombre)
              .input('inNuevoTipoDocId', sql.VarChar(64), nuevoTipoDocId)
              .input('inNuevoDocId', sql.VarChar(64), nuevoDocId)
              .input('inNuevaFechaNac', sql.VarChar(64), nuevaFechaNac)
              .input('inNuevoPuesto', sql.VarChar(64), nuevoPuesto)
              .input('inNuevoDepartamento', sql.VarChar(64), nuevoDepartamento)
              .input('inUsername', sql.VarChar(64), username)
              .input('inIpAdress', sql.VarChar(64), ipAdress)
              .output('outResultCode', sql.Int)
              .execute('ModificarEmpleado');
  
          return [resultado.output.outResultCode];
      } catch (error) {
          console.error('Error ejecutando el SP ModificarEmpleado:', error)
      }
}
