import sql from 'mssql';
import { conectarDB } from "../config/database.js";

export async function regresarAdmin(username,ipAdress) {
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inUsername', sql.VarChar(64), username)
            .input('inIpAdress', sql.VarChar(64),ipAdress)
            .output('outResultCode', sql.Int)
            .execute('RegresarAdmin');

            return resultado.output.outResultCode;
        
    } catch (err) {
        console.error('Error ejecutando el SP:', err)
    }
}

export async function listarMes(username,ipAdress) {
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inUsername', sql.VarChar(64), username)
            .input('inIpAdress', sql.VarChar(64),ipAdress)
            .output('outResultCode', sql.Int)
            .execute('ConsultarPlanillaMensual');

            return resultado.recordset;

    } catch (err) {
        console.error('Error ejecutando el SP:', err)
    }
}

export async function desplegarDeducciones(username,idMes){
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inUsername', sql.VarChar(64), username)
            .input('inIdMes', sql.INT,idMes)
            .output('outResultCode', sql.Int)
            .execute('DesgloseDeducciones');
            return resultado.recordsets;

    } catch (err) {
        console.error('Error ejecutando el SP:', err)
    }
}  

/*********Funciones encargadas de generas tablas*******/
export function setearTabla(transacciones){
  let tabla = `
    <div class="relative overflow-hidden shadow-md rounded-lg mt-4">
      <table class="table-fixed w-full text-left border-collapse">
        <thead class="uppercase bg-[#003bb2] text-[#e5e7eb]">
          <tr>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Salario Bruto</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Total Deducciones</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold"> SalarioNeto</th>
          </tr>
        </thead>
        <tbody class="bg-white text-[#6b7280]">
  `;

  for (const trans of transacciones) {
    tabla += `
      <tr>
        <td class="py-3 px-4 border border-gray-200 text-center">${trans.SalarioBruto}</td>
       <td class="hover:bg-gray-200 py-3 px-4 border border-gray-200 text-center ver-deducciones"
        data-idmes="${trans.IdMes}">
        ${trans.TotalDeducciones}
      </td>
        <td class="py-3 px-4 border border-gray-200 text-center">${trans.SalarioNeto}</td>
      </tr>
    `;
  }

  tabla += `
        </tbody>
      </table>
    </div>
  `;

  return tabla

}

export function setearDesglose(deducciones1, deducciones2){

  let tabla = `
    <div class="relative overflow-hidden shadow-md rounded-lg mt-4">
      <table class="table-fixed w-full text-left border-collapse">
        <thead class="uppercase bg-[#003bb2] text-[#e5e7eb]">
          <tr>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Nombre</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Porcentaje Aplicado</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold"> Monto Deduccion</th>
          </tr>
        </thead>
        <tbody class="bg-white text-[#6b7280]">
  `;

  for (const des of deducciones1) {
    tabla += `
      <tr>
        <td class="py-3 px-4 border border-gray-200 text-center">${des.Nombre}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${des.PorcentajeAplicado}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${des.MontoDeduccion}</td>
      </tr>
    `;
  }
  for (const des of deducciones2) {
    tabla += `
      <tr>
        <td class="py-3 px-4 border border-gray-200 text-center">${des.Nombre}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${des.PorcentajeAplicado}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${des.MontoDeduccion}</td>
      </tr>
    `;
  }
  tabla += `
        </tbody>
      </table>
    </div>
  `;

  return tabla
}