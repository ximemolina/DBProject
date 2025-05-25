import * as functionsDB from '../model/generalDB.js'
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export const mainFile = async (req, res) => {
    res.sendFile(path.join(__dirname, '../views/login.html')); //sirve el html de la página inicial
};

export const getError = async (req,res) => {
    const {codigo} = req.body;
    const resultado = await functionsDB.mostrarDescripcion(codigo);
    res.json({resultado});
};

// Controlador para registrar el evento de logout
export const logout = async (req,res) => {
    const {username,ipAdress} = req.body;
    const resultado = await functionsDB.logout(username,ipAdress);
    res.json({resultado})
};
