import sql from 'mssql';
import { conectarDB } from "../config/database.js";

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

async function pruebaLogout() {
    try {
        const username = "Goku";
        const ipAddress = "192.168.1.100";

        const resultado = await logout(username, ipAddress);
        console.log("Código de resultado:", resultado);
    } catch (error) {
        console.error("Error en la prueba de logout:", error);
    }
}

// Ejecutar la prueba
pruebaLogout();


// Ejecuta el sp para listar a todos los empleados activos
export async function listarEmpleados() {
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .output('outResultCode', sql.INT)
            .execute('ListarEmpleados');

        return [resultado.output.outResultCode, resultado.recordset];
    }
    catch (err) {
        console.error('Error ejecutando el SP ListarEmpleados:', err)
    }
}

// Genera la tabla traida de la BD en HTML
export function generarTabla(tabla) {
    let tableHTML = `
        <div class="relative overflow-hidden rounded-lg shadow-md">
            <table class="w-full table-fixed text-left">
                <thead class="bg-[#003bb2] text-[#e5e7eb] uppercase" style="background-color: rgb(0, 59, 178); color: rgb(229, 231, 235);">
                    <tr>
                        <td class="border border-gray-200 p-4 py-1 text-center font-bold">NOMBRE</td>
                <td class="border border-gray-200 p-4 py-1 text-center font-bold">PUESTO</td>
                <td class="border border-gray-200 p-4 py-1 text-center font-bold">SELECCIONAR</td>
                    </tr>
                </thead>
                <tbody class="bg-[#FFFFFF] bg-white text-[#6b7280] text-gray-500" style="background-color: #FFFFFF; color: #6b7280;">
    `;

    tabla.forEach(item => {
        tableHTML += `
            <tr class="py-5">
                <td class="border border-gray-200 p-4 py-5 text-center">${item.Nombre}</td>
                <td class="border border-gray-200 p-4 py-5 text-center">${item.Puesto}</td>
                <td class="border border-gray-200 p-4 py-5 text-center"><input type="checkbox" class="fila-checkbox" value="${item.Nombre}"></td>
            </tr>
        `;
    });

    tableHTML += `
                </tbody>
            </table>
        </div>
    `;

    return tableHTML;
}

// Ejecuta el sp para listar a todos los empleados activos por nombre
export async function listarEmpleadosNombre(input, username, ipAdress) {
    try {
        let pool = await conectarDB();
        let resultado = await pool.request()
        .input('inNombre', sql.VarChar(64), input)
        .input('inUsername', sql.VarChar(64), username)
        .input('inIpAdress', sql.VarChar(64), ipAdress)
        .output('outResultCode', sql.Int)
        .execute('ListarEmpleadosNombre');
        
        return [resultado.output.outResultCode, resultado.recordset];
    }
    catch (err) {
        console.error('Error ejecutando el SP ListarEmpleadosNombre:', err)
    }
}