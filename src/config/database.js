import sql from 'mssql';
import * as dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

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

export async function conectarDB() { //conexión con base de datos
    try {
        let pool = await sql.connect(config);
        console.log('Conexión exitosa a SQL Server');
        return pool;
    } catch (err) {
        console.error('Error en la conexión a la base de datos:', err);
    }
}
