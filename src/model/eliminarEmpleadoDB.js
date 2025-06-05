import sql from 'mssql';
import { conectarDB } from "../config/database.js";

export async function eliminarEmpleado(docId,username,ipAdress){
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inDocId', sql.VarChar(64), docId)
            .input('inUsername', sql.VarChar(64), username)
            .input('inIpAdress', sql.VarChar(64), ipAdress)
            .output('outResultCode', sql.Int)
            .execute('EliminarEmpleado');

            return resultado.output.outResultCode;
        
    } catch (err) {
        console.error('Error ejecutando el SP:', err)
    }   
};