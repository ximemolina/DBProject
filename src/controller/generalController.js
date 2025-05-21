import * as functionsDB from '../model/errorDB.js'
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export const mainFile = async (req, res) => {
    res.sendFile(path.join(__dirname, '../views/principalAdmin.html')); //sirve el html de la página inicial
};

export const getError = async (req,res) => {
    const {codigo} = req.body;
    const resultado = await functionsDB.mostrarDescripcion(codigo);
    res.json({resultado});
};