import sql from 'mssql';
import { conectarDB } from "../config/database.js";

//Insertar nuevo empleado
export async function insertarEmpleado(nombreActual, nuevoNombre, nuevoTipoDocId, 
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