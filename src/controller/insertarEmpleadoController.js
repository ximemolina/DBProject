import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import * as insertarDB from '../model/insertarEmpleadoDB.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Controlador para pasar a la pagina de insercion
export const insertarFile = async (req, res) => {
    res.sendFile(path.join(__dirname, '../views/insertarEmpleado.html'));
};

//Controlador para insertar nuevo empleado
export const insertarEmpleado = async (req, res) => {
    try {
        const { nombre, idTipoDocId, docId, fechaNac, 
                nombrePuesto, idDepartamento, usuario, 
                password, username, ipAdress } = req.body;
        const response = await insertarDB.insertarEmpleado(
                        nombre, idTipoDocId, docId, fechaNac, 
                        nombrePuesto, idDepartamento, usuario, 
                        password, username, ipAdress);

        const outResultCode = response[0];

        res.json({ outResultCode });
    } catch (error) {
        console.error("Error ejecutando insertarEmpleado:", error);
        res.status(500).json({ error: "Error interno en el servidor." });
    }
};