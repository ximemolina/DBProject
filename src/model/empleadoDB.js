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

export async function listarSemana(username,ipAdress){
     try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inUsername', sql.VarChar(64), username)
            .input('inIpAdress', sql.VarChar(64),ipAdress)
            .output('outResultCode', sql.Int)
            .execute('ConsultarPlanillaSemanal');

            return resultado.recordset;

    } catch (err) {
        console.error('Error ejecutando el SP:', err)
    } 
}

export async function desplegarDeduccionesSemana(username,idSemana){
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inUsername', sql.VarChar(64), username)
            .input('inIdSemana', sql.INT,idSemana)
            .output('outResultCode', sql.Int)
            .execute('DesgloseDeduccionesSemanal');
            return resultado.recordsets;

    } catch (err) {
        console.error('Error ejecutando el SP:', err)
    }
} 

export async function desplegarSalarioSemana(username,idSemana){
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inUsername', sql.VarChar(64), username)
            .input('inIdSemana', sql.INT,idSemana)
            .output('outResultCode', sql.Int)
            .execute('DesgloseSalario');
            return resultado.recordsets;

    } catch (err) {
        console.error('Error ejecutando el SP:', err)
    }
} 

export async function listarMovimientos(username) {
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inUsername', sql.VarChar(64), username)
            .output('outResultCode', sql.Int)
            .execute('ConsultarMovimientos');

            return resultado.recordset;

    } catch (err) {
        console.error('Error ejecutando el SP:', err)
    }
}

export async function detalleMovs(idMov,idMovtipo) {
    try {
        let pool = await conectarDB();

        let resultado = await pool.request()
            .input('inIdMovimiento', sql.VarChar(64), idMov)
            .input('inIdTipoMovimiento', sql.VarChar(64), idMovtipo)
            .output('outResultCode', sql.Int)
            .execute('DesgloseMovimientos');

            return resultado.recordset;

    } catch (err) {
        console.error('Error ejecutando el SP:', err)
    }
}

/*********Funciones encargadas de generas tablas*******/
export function setearTablaMes(transacciones){
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

export function setearTablaMovs(transacciones){

  let tabla = `
    <div class="relative overflow-hidden shadow-md rounded-lg mt-4">
      <table class="table-fixed w-full text-left border-collapse">
        <thead class="uppercase bg-[#003bb2] text-[#e5e7eb]">
          <tr>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Fecha</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Monto</th>
          </tr>
        </thead>
        <tbody class="bg-white text-[#6b7280]">
  `;

  for (const trans of transacciones) {
    tabla += `
      <tr>
        <td class="py-3 px-4 border border-gray-200 text-center">${trans.Fecha}</td>
        <td class="hover:bg-gray-200 py-3 px-4 border border-gray-200 text-center ver-movs"
            data-idmovtipo="${trans.IdTipoMovimiento}"
            data-idmov="${trans.IdMovimiento}">
          ${trans.Monto}
        </td>
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

export function setearTablaSemana(transacciones){
  let tabla = `
    <div class="relative overflow-hidden shadow-md rounded-lg mt-4">
      <table class="table-fixed w-full text-left border-collapse">
        <thead class="uppercase bg-[#003bb2] text-[#e5e7eb]">
          <tr>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Salario Bruto</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Total Deducciones</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold"> Salario Neto</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Cantidad de Horas Ordinarias</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Cantidad de Horas Extras Normales</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Cantidad de Horas Extras Dobles</th>
          </tr>
        </thead>
        <tbody class="bg-white text-[#6b7280]">
  `;

  for (const trans of transacciones) {
    tabla += `
      <tr>
      <td class="hover:bg-gray-200 py-3 px-4 border border-gray-200 text-center ver-semana"
        data-idsemana="${trans.IdSemana}">
        ${trans.SalarioBruto}
      </td>
       <td class="hover:bg-gray-200 py-3 px-4 border border-gray-200 text-center ver-deducciones"
        data-idsemana="${trans.IdSemana}">
        ${trans.TotalDeducciones}
      </td>
        <td class="py-3 px-4 border border-gray-200 text-center">${trans.SalarioNeto}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${trans.HorasOrdinarias}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${trans.HorasExtraNormales}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${trans.HorasExtraDobles}</td>
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

export function setearDesgloseSalario(deducciones1){

  let tabla = `
    <div class="relative overflow-hidden shadow-md rounded-lg mt-4">
      <table class="table-fixed w-full text-left border-collapse">
        <thead class="uppercase bg-[#003bb2] text-[#e5e7eb]">
          <tr>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Hora Entrada</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Hora Salida</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Hora Ordinaria</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Monto Hora Ordinaria</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Hora Extra Normal</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Monto Hora Extra Normal</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Hora Extra Doble</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Monto Hora Extra Doble</th>
          </tr>
        </thead>
        <tbody class="bg-white text-[#6b7280]">
  `;

  for (const des of deducciones1) {
    tabla += `
      <tr>
        <td class="py-3 px-4 border border-gray-200 text-center">${formatearHora(des.HoraEntrada)}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${formatearHora(des.HoraSalida)}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${des.HoraOrdinaria}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${des.MontoHoraOrdinaria}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${des.HoraExtraNormal}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${des.MontoHoraExtraNormal}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${des.HoraExtraDoble}</td>
        <td class="py-3 px-4 border border-gray-200 text-center">${des.MontoExtraDoble}</td>        
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

export function setearDesgloseMovimientos(deducciones1) {
  // Verificamos si todos los registros tienen Horas == 0
  const todosSonCero = deducciones1.every(des => des.Horas == 0);

  let tabla = `
    <div class="relative overflow-hidden shadow-md rounded-lg mt-4">
      <table class="table-fixed w-full text-left border-collapse">
        <thead class="uppercase bg-[#003bb2] text-[#e5e7eb]">
          <tr>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Nombre de Movimiento</th>`;

  if (!todosSonCero) {
    tabla += `
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Cantidad Horas de Movimiento</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Hora Inicio de Asistencia</th>
            <th class="py-3 px-4 border border-gray-200 text-center font-bold">Hora Fin de Asistencia</th>`;
  }

  tabla += `
          </tr>
        </thead>
        <tbody class="bg-white text-[#6b7280]">
  `;

  for (const des of deducciones1) {
    if (des.Horas == 0) {
      tabla += `
        <tr>
          <td class="py-3 px-4 border border-gray-200 text-center">${des.Nombre}</td>`;
      if (!todosSonCero) {
        tabla += `<td colspan="3" class="py-3 px-4 border border-gray-200 text-center text-gray-400 italic">Sin horas registradas</td>`;
      }
      tabla += `</tr>`;
    } else {
      tabla += `
        <tr>
          <td class="py-3 px-4 border border-gray-200 text-center">${des.Nombre}</td>
          <td class="py-3 px-4 border border-gray-200 text-center">${des.Horas}</td>
          <td class="py-3 px-4 border border-gray-200 text-center">${formatearHora(des.HoraInicio)}</td>
          <td class="py-3 px-4 border border-gray-200 text-center">${formatearHora(des.HoraFin)}</td>
        </tr>
      `;
    }
  }

  tabla += `
        </tbody>
      </table>
    </div>
  `;

  return tabla;
}

function formatearHora(fecha) {
  const date = new Date(fecha);
  const horas = date.getHours().toString().padStart(2, '0');
  const minutos = date.getMinutes().toString().padStart(2, '0');
  return `${horas}:${minutos}`;
}