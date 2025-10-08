async function handler(event) {
    // Headers
    const headers = {};
    %{~ for header, command in cc ~}
    headers[${header}] = ${command};
    %{~ endfor ~}

    // Compute response
    const response = {
        statusCode: 200,
        statusDescription: "OK",
        headers,
        body: ""
    }

    // Return the response to viewers
    return response;
}
