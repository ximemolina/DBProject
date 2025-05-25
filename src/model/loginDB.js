import sql from 'mssql';
import { conectarDB } from "../config/database.js";

export async function revisarLogin(username,password,ipAdress) {
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inUsername', sql.VarChar(64), username)
            .input('inPassword', sql.VarChar(64),password)
            .input('inIpAdress', sql.VarChar(64),ipAdress)
            .output('outResultCode', sql.Int)
            .execute('RevisarUsuarioContrasena');

            return resultado.output.outResultCode;
        
    } catch (err) {
        console.error('Error ejecutando el SP:', err)
    }
}

export async function revisarTipoUsuario(username) {
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inUsername', sql.VarChar(64), username)
            .output('outResultCode', sql.Int)
            .execute('RevisarTipoUsuario');

            return resultado.recordset[0].Nombre;
        
    } catch (err) {
        console.error('Error ejecutando el SP:', err)
    }
}