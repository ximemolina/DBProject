import sql from 'mssql';
import { conectarDB } from "../config/database.js";

//Insertar nuevo empleado
export async function insertarEmpleado(nombre, idTipoDocId, docId, fechaNac, 
                                        nombrePuesto, idDepartamento, usuario, 
                                        password, username, ipAdress) {
  try {
          let pool = await conectarDB();
  
          let resultado = await pool.request()
            .input('inNombre', sql.VarChar(64), nombre)
            .input('inIdTipoDocId', sql.Int, idTipoDocId)
            .input('inDocId', sql.VarChar(64), docId)
            .input('inFechaNac', sql.Date, fechaNac)
            .input('inNombrePuesto', sql.VarChar(64), nombrePuesto)
            .input('inIdDepartamento', sql.Int, idDepartamento)
            .input('inUsuario', sql.VarChar(64), usuario)
            .input('inPassword', sql.VarChar(64), password)
            .input('inUsername', sql.VarChar(64), username)
            .input('inIpAdress', sql.VarChar(64), ipAdress)
            .output('outResultCode', sql.Int)
            .execute('InsertarEmpleado');
  
          return [resultado.output.outResultCode];
      } catch (error) {
          console.error('Error ejecutando el SP InsertarEmpleado:', error)
      }
}