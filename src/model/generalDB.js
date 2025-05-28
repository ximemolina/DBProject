import sql from 'mssql';
import { conectarDB } from "../config/database.js";

export async function mostrarDescripcion(codigo) {
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inCodeError', sql.Int, codigo)
            .output('outResultCode', sql.Int)
            .execute('MostrarError');

            return resultado.recordset;
        
    } catch (err) {
        console.error('Error ejecutando el SP:', err)
    }
}

// Ejecuta el sp para registrar el evento de logout
export async function logout(username,IpAdress){
    try {
        let pool = await conectarDB();
        let resultado = await pool.request()
            .input('inUsername', sql.VarChar(64), username)
            .input('inIpAdress', sql.VarChar(64), IpAdress)
            .output('outResultCode', sql.Int)
            .execute('Logout');

            return resultado.output.outResultCode;
        
    } catch (err) {
        console.error('Error ejecutando el SP:', err)
    }      
};
