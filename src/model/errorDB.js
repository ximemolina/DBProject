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