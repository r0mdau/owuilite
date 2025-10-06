// Custom Enterprise MCP Server Example
// This server provides access to enterprise CRM data

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');

// Initialize server
const server = new Server({
  name: 'enterprise-crm-server',
  version: '1.0.0',
}, {
  capabilities: {
    tools: {},
    resources: {}
  }
});

// Tool: Query CRM for customer information
server.tool('query_customer', 
  'Query customer information from enterprise CRM',
  {
    customer_id: {
      type: 'string',
      description: 'Customer ID to query',
      required: true
    },
    fields: {
      type: 'array',
      description: 'Fields to return (optional)',
      items: {
        type: 'string'
      }
    }
  },
  async ({ customer_id, fields }) => {
    try {
      // Connect to enterprise CRM API
      // This is a placeholder - implement actual CRM connection
      const customerData = await fetchCustomerData(customer_id, fields);
      
      return {
        content: [{
          type: 'text',
          text: JSON.stringify(customerData, null, 2)
        }]
      };
    } catch (error) {
      return {
        content: [{
          type: 'text',
          text: `Error querying customer: ${error.message}`
        }],
        isError: true
      };
    }
  }
);

// Tool: Create support ticket
server.tool('create_support_ticket',
  'Create a support ticket in the enterprise system',
  {
    customer_id: {
      type: 'string',
      description: 'Customer ID',
      required: true
    },
    title: {
      type: 'string',
      description: 'Ticket title',
      required: true
    },
    description: {
      type: 'string',
      description: 'Ticket description',
      required: true
    },
    priority: {
      type: 'string',
      description: 'Ticket priority (low, medium, high, critical)',
      enum: ['low', 'medium', 'high', 'critical']
    }
  },
  async ({ customer_id, title, description, priority = 'medium' }) => {
    try {
      const ticket = await createTicket({
        customer_id,
        title,
        description,
        priority
      });
      
      return {
        content: [{
          type: 'text',
          text: `Support ticket created successfully.\nTicket ID: ${ticket.id}\nStatus: ${ticket.status}`
        }]
      };
    } catch (error) {
      return {
        content: [{
          type: 'text',
          text: `Error creating ticket: ${error.message}`
        }],
        isError: true
      };
    }
  }
);

// Resource: Customer list
server.resource('customers',
  'List of all active customers',
  'application/json',
  async () => {
    try {
      const customers = await fetchAllCustomers();
      return {
        contents: [{
          uri: 'crm://customers',
          mimeType: 'application/json',
          text: JSON.stringify(customers, null, 2)
        }]
      };
    } catch (error) {
      throw new Error(`Failed to fetch customers: ${error.message}`);
    }
  }
);

// Resource: Open tickets
server.resource('open-tickets',
  'List of all open support tickets',
  'application/json',
  async () => {
    try {
      const tickets = await fetchOpenTickets();
      return {
        contents: [{
          uri: 'crm://open-tickets',
          mimeType: 'application/json',
          text: JSON.stringify(tickets, null, 2)
        }]
      };
    } catch (error) {
      throw new Error(`Failed to fetch tickets: ${error.message}`);
    }
  }
);

// Placeholder functions - implement with actual CRM API
async function fetchCustomerData(customerId, fields) {
  // Implement actual CRM API call
  return {
    id: customerId,
    name: 'Example Customer',
    email: 'customer@example.com',
    status: 'active',
    // ... more fields
  };
}

async function createTicket(ticketData) {
  // Implement actual ticket creation
  return {
    id: 'TICKET-' + Date.now(),
    status: 'open',
    ...ticketData
  };
}

async function fetchAllCustomers() {
  // Implement actual customer list fetch
  return [];
}

async function fetchOpenTickets() {
  // Implement actual ticket fetch
  return [];
}

// Start server
const transport = new StdioServerTransport();
server.connect(transport).catch((error) => {
  console.error('Failed to start server:', error);
  process.exit(1);
});
