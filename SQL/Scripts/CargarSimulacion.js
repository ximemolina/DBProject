import sql from 'mssql';
import fs from "fs";
import * as dotenv from 'dotenv';

dotenv.config();  //uso de variables de entorno

const xmlPath = process.env.rutaSimulacion;

const config ={
    server: process.env.server,
    port: parseInt(process.env.port), 
    database: process.env.database,
    user: process.env.user,
    password: process.env.password,
    options:{
        encrypt: true,
        trustServerCertificate: true
    },
};

let xmlContent = fs.readFileSync(xmlPath, 'utf-8');
// Elimina cualquier línea que comience con <?xml ... ?>
xmlContent = xmlContent.replace(/<\?xml[^>]*\?>/, '');


export async function conectarDB() { //conexión con base de datos
    try {
        let pool = await sql.connect(config);
        console.log('Conexión exitosa a SQL Server');
        return pool;
    } catch (err) {
        console.error('Error en la conexión a la base de datos:', err);
    }
}

async function enviarXML() { //ejecuta sp para cargar datos catalogo de xml a tablas de la base de datos
    try {
        const pool = await sql.connect(config);

        let resultado = await pool.request()
            .input('inArchivoXML', sql.NVarChar(sql.MAX), xmlContent)
            .output('outResultCode', sql.Int)
            .execute('CargaSimulacion');
        
        console.log(resultado.output);
        console.log("XML enviado y procesado en SQL Server.");
        await sql.close();
    } catch (err) {
        console.error("Error:", err);
    }
}

enviarXML();