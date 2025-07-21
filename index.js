exports.handler = async (event, context) => {

    // Log event and context

    console.log("Received event:", JSON.stringify(event, null, 2));

    console.log("Execution context:", JSON.stringify(context, null, 2));

    // Simple response

    return {

        statusCode: 200,

        body: JSON.stringify({

            message: "Hello from Lambda!",

            input: event,

        }),

    };

};

// https://www.geeksforgeeks.org/devops/aws-lambda-function-handler-in-nodejs/