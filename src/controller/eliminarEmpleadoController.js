import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import * as functionsDB from '../model/eliminarEmpleadoDB.js'

export const eliminarEmpleado = async (req,res) => {
    const {docId,username,IpAdress} = req.body;
    const resultado = await functionsDB.eliminarEmpleado(docId,username,IpAdress);
    res.json({resultado});
};