import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import * as principalAdminFunctions from '../model/principalAdminDB.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Controlador para pasar a la pagina principal del admin
export const principalAdminFile = async (req, res) => {
    res.sendFile(path.join(__dirname, '../views/principalAdmin.html'));
};

// Controlador para registrar el evento de logout
export const logout = async (req,res) => {
    const {username,ipAdress} = req.body;
    const resultado = await principalAdminFunctions.logout(username,ipAdress);
    res.json({resultado})
};

// Controlador para enviar la tabla del BD como HTML
export const listarEmpleados = async (req,res) => {
    const tabla = await principalAdminFunctions.listarEmpleados();
    if (tabla[0] == 0) {        //Revisa que el resultCode sea 0: exito
        let tableHTML = principalAdminFunctions.generarTabla(tabla[1]);
        res.send(tableHTML);
    }
    else {
        console.log("Error: " + tabla, "No se pudo cargar la tabla")
    }
};

// Controlador para enviar la tabla por nombre del BD como HTML
export const listarEmpleadosNombre = async (req,res) => {
    const { input, username, ipAdress } = req.body;
    const response = await principalAdminFunctions.listarEmpleadosNombre(input, username, ipAdress);
    const outResultCode = response[0];
    const recordset = response[1];
    if (outResultCode == 0) {        //Revisa que el resultCode sea 0: exito
        let tableHTML = principalAdminFunctions.generarTabla(recordset);
        res.json({outResultCode, tableHTML});
    }
    else {
        console.log("Error: " + outResultCode, "No se pudo cargar la tabla")
        res.json({outResultCode});
    }
};
