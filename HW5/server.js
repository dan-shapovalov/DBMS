//******************************************************************************
//*** set up an HTTP server off port 3000
//******************************************************************************
const express = require('express');
const app = express();
const PORT = 3000;

// Requires the exported pool object from the local 'mysql.js' file
const pool = require('./mysql');

// Keep book values from being interpreted as HTML tags (just additional security feature)
function escapeHtml(value) {
    return String(value ?? '').replace(/[&<>"']/g, char => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    })[char]);
}

//******************************************************************************
//*** receive GET requests from the browser
//******************************************************************************
app.get('/', async (req, res) => {
    const category = req.query.category;
    const author = req.query.author;
    const format = req.query.format;

    let sql_query = 'SELECT bookid, title, author, category, price FROM books';
    let params = [];

    // Use a prepared statement for whichever search parameter was provided
    if (category) {
        sql_query += ' WHERE category = ?';
        params = [category];
    } else if (author) {
        sql_query += ' WHERE author = ?';
        params = [author];
    }

    try {
        const [result, fields] = await pool.execute(sql_query, params);

        if (format === 'text') {
            // start creating the HTML body for the browser
            let html_body = '<HTML><STYLE>body{font-family:arial}</STYLE><BODY><TABLE BORDER=1>';

            // print column headings
            html_body += '<TR>';
            for (let i = 0; i < fields.length; i++) {
                html_body += `<TH>${escapeHtml(fields[i].name.toUpperCase())}</TH>`;
            }
            html_body += '</TR>';

            // print rows of table data
            for (let i = 0; i < result.length; i++) {
                const book = result[i];
                html_body += `<TR>
                    <TD>${escapeHtml(book.bookid)}</TD>
                    <TD>${escapeHtml(book.title)}</TD>
                    <TD>${escapeHtml(book.author)}</TD>
                    <TD>${escapeHtml(book.category)}</TD>
                    <TD>${escapeHtml(book.price)}</TD>
                </TR>`;
            }

            html_body += '</TABLE></BODY></HTML>';
            return res.send(html_body);
        }

        // JSON is the default response, including when format=json.
        res.json(result);
    } catch (err) {
        console.error('SQL Error:', err);
        res.status(500).json({ error: 'An error occurred while fetching books.' });
    }
});

// server waits for incoming requests
app.listen(PORT, function () {
    console.log('NodeJS app listening on port ' + PORT);
});
