import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import * as functionsDB from '../model/empleadoDB.js'

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export const EmpleadoMainFile = async (req, res) => {
    res.sendFile(path.join(__dirname, '../views/principalEmpleado.html')); //sirve el html de la página inicial
};

export const ConsultaMesFile = async (req, res) => {
    res.sendFile(path.join(__dirname, '../views/consultarMes.html')); //sirve el html de consulta de mes
};

export const ConsultaSemanaFile = async (req, res) => {
    res.sendFile(path.join(__dirname, '../views/consultarSemana.html')); //sirve el html de consulta de semana
};

export const ConsultaMovimientoFile = async (req, res) => {
    res.sendFile(path.join(__dirname, '../views/consultarMovimientos.html')); //sirve el html de consulta de semana
};

export const regresarAdmin = async (req,res) => {
    const {username,ipAdress} = req.body;
    const resultado = await functionsDB.regresarAdmin(username,ipAdress);
    res.json({resultado})
};

export const listarPlanillaMes = async (req,res) => {
    const {username,ipAdress} = req.body;
    const resultado = await functionsDB.listarMes(username,ipAdress);
    const tabla = functionsDB.setearTablaMes(resultado);
    res.json({tabla})
};

export const desplegarDeducciones = async (req,res) => {
    const {username,idMes} = req.body;
    const resultado = await functionsDB.desplegarDeducciones(username,idMes);
    const tabla = functionsDB.setearDesglose(resultado[0],resultado[1]);
    res.json({tabla})
};

export const listarPlanillaSemana = async (req,res) => {
    const {username,ipAdress} = req.body;
    const resultado = await functionsDB.listarSemana(username,ipAdress);
    const tabla = functionsDB.setearTablaSemana(resultado);
    res.json({tabla})
};

export const desplegarDeduccionesSemana = async (req,res) => {
    const {username,idSemana} = req.body;
    const resultado = await functionsDB.desplegarDeduccionesSemana(username,idSemana);
    const tabla = functionsDB.setearDesglose(resultado[0],resultado[1]);
    res.json({tabla})
};

export const desplegarSalario = async (req,res) => {
    const {username,idSemana} = req.body;
    const resultado = await functionsDB.desplegarSalarioSemana(username,idSemana);
    const tabla = functionsDB.setearDesgloseSalario(resultado[0]);
    res.json({tabla})
};

export const listarMovimientos = async (req,res) => {
    const {username} = req.body;
    const resultado = await functionsDB.listarMovimientos(username);
    const tabla = functionsDB.setearTablaMovs(resultado);
    res.json({tabla})
};

export const desplegarMovs = async (req,res) => {
    const {idMov,idMovtipo} = req.body;
    const resultado = await functionsDB.detalleMovs(idMov,idMovtipo);
    const tabla = functionsDB.setearDesgloseMovimientos(resultado);
    res.json({tabla})
};