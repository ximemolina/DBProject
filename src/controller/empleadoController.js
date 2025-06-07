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

export const regresarAdmin = async (req,res) => {
    const {username,ipAdress} = req.body;
    const resultado = await functionsDB.regresarAdmin(username,ipAdress);
    res.json({resultado})
};

export const listarPlanillaMes = async (req,res) => {
    const {username,ipAdress} = req.body;
    const resultado = await functionsDB.listarMes(username,ipAdress);
    const tabla = functionsDB.setearTabla(resultado);
    res.json({tabla})
};

export const desplegarDeducciones = async (req,res) => {
    const {username,idMes} = req.body;
    const resultado = await functionsDB.desplegarDeducciones(username,idMes);
    const tabla = functionsDB.setearDesglose(resultado[0],resultado[1]);
    res.json({tabla})
};