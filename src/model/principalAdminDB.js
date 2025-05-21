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
        <div class="shadow-md rounded-lg relative">
            <table class="table-fixed w-full text-left">
                <thead class="uppercase bg-[#2856b3] text-[#ffffff]" style="background-color: #2856b3; color: #ffffff;">
                    <tr>
                        <td class="py-2 border border-gray-200 text-center p-4">NOMBRE</td>
                        <td class="py-2 border border-gray-200 text-center p-4">PUESTO</td>
                        <td class="py-2 border border-gray-200 text-center p-4">SELECCIONAR</td>
                    </tr>
                </thead>
                <tbody class="bg-white text-gray-500 bg-[#FFFFFF] text-[#6b7280]" style="background-color: #FFFFFF; color: #6b7280;">
    `;

    tabla.forEach(item => {
        tableHTML += `
            <tr class="py-0">
                <td class="py-0 border border-gray-200 text-center p-4">${item.Nombre}</td>
                <td class="py-0 border border-gray-200 text-center p-4">${item.Puesto}</td>
                <td class="py-0 border border-gray-200 text-center p-4"><input type="checkbox" class="fila-checkbox" value="${item.Nombre}"></td>
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