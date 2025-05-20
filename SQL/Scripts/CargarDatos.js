import sql from 'mssql';
import fs from "fs";
import * as dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';


const xmlPath = 'C:/Users/ximen/OneDrive/Escritorio/catalogos.xml';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Cargar .env desde la raíz del proyecto
dotenv.config({ path: path.resolve(__dirname, '../../.env') }); //uso de variables de entorno

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
            .execute('CargarDatos');
        
        console.log(resultado.output)
        console.log("XML enviado y procesado en SQL Server.");
        await sql.close();
    } catch (err) {
        console.error("Error:", err);
    }
}

enviarXML();