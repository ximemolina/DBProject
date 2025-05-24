import sql from 'mssql';
import { conectarDB } from "../config/database.js";

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

async function probarEndpoint() {
    try {
        let resultado = await listarEmpleados();
        console.log('Código de resultado:', resultado[0]);
        console.log('Lista de empleados:', resultado[1]);
    } catch (error) {
        console.error('Error al probar el endpoint:', error);
    }
}

probarEndpoint();


// Genera la tabla traida de la BD en HTML
export function generarTabla(tabla) {
    let tableHTML = `
        <div class="relative overflow-hidden rounded-lg shadow-md">
            <table class="w-full table-fixed text-left">
                <thead class="bg-[#003bb2] text-[#e5e7eb] uppercase" style="background-color: rgb(0, 59, 178); color: rgb(229, 231, 235);">
                    <tr>
                        <td class="border border-gray-200 p-4 py-1 text-center">DOCUMENTO IDENTIDAD</td>
                        <td class="border border-gray-200 p-4 py-1 text-center">NOMBRE</td>
                        <td class="border border-gray-200 p-4 py-1 text-center">PUESTO</td>
                        <td class="border border-gray-200 p-4 py-1 text-center">SELECCIONAR</td>
                    </tr>
                </thead>
                <tbody class="bg-[#FFFFFF] bg-white text-[#6b7280] text-gray-500" style="background-color: #FFFFFF; color: #6b7280;">
    `;

    tabla.forEach(item => {
        tableHTML += `
            <tr class="py-5">
                <td class="border border-gray-200 p-4 py-5 text-center">${item.Identificacion}</td>
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
/*export async function listarEmpleadosNombre(input, username, ipAdress) {
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

// Ejecuta el sp para listar a todos los empleados activos por documento de identidad
export async function listarEmpleadosId(input, username, ipAdress) {
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inId', sql.VarChar(64), input)
            .input('inUsername', sql.VarChar(64), username)
            .input('inIpAdress', sql.VarChar(64), ipAdress)
            .output('outResultCode', sql.Int)
            .execute('ListarEmpleadosId');

        return [resultado.output.outResultCode, resultado.recordset];
    }
    catch (err) {
        console.error('Error ejecutando el SP ListarEmpleadosId:', err)
    }
}*/