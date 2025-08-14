using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Threading;
using System.Threading.Tasks;
using ARSoft.Tools.Net.Dns;

var port = int.Parse(Environment.GetEnvironmentVariable("DNS_PORT") ?? "53");
var bindAddress = IPAddress.Parse(Environment.GetEnvironmentVariable("BIND_ADDRESS") ?? "0.0.0.0");

Console.WriteLine($"Starting DNS server on {bindAddress}:{port}");

var server = new DnsServer(bindAddress, port, port);
server.QueryReceived += async (sender, e) =>
{
    var query = e.Query as DnsMessage;
    var response = query.CreateResponseInstance();

    foreach (var question in query.Questions.Where(q => q.RecordType == RecordType.Txt))
    {
        try
        {
            var domainName = question.Name.ToString().TrimEnd('.');
            
            // Simple approach: remove common domain suffixes and convert separators to spaces
            var questionText = domainName
                .Replace(".mindworking.local", "")
                .Replace(".", " ")
                .Replace("-", " ");
            
            // Debug log
            Console.WriteLine($"DNS query: '{domainName}' -> question: '{questionText}'");
            
            var answer = await AskChatGpt(questionText);
            if (!string.IsNullOrEmpty(answer))
            {
                // Split long answers into 255-byte chunks as required by TXT records
                var chunks = SplitTextIntoChunks(answer, 255);
                response.AnswerRecords.Add(new TxtRecord(question.Name, 300, chunks));
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error processing question {question.Name}: {ex.Message}");
            response.AnswerRecords.Add(new TxtRecord(question.Name, 300, new List<string> { $"Error: {ex.Message}" }));
        }
    }

    response.ReturnCode = ReturnCode.NoError;
    e.Response = response;
};

server.Start();

Console.WriteLine("DNS server started. Running indefinitely...");

// Keep the application running
var cancellationTokenSource = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) =>
{
    e.Cancel = true;
    cancellationTokenSource.Cancel();
};

try
{
    await Task.Delay(Timeout.Infinite, cancellationTokenSource.Token);
}
catch (TaskCanceledException)
{
    Console.WriteLine("Shutting down DNS server...");
}

server.Stop();

static List<string> SplitTextIntoChunks(string text, int maxChunkSize)
{
    var chunks = new List<string>();
    for (int i = 0; i < text.Length; i += maxChunkSize)
    {
        chunks.Add(text.Substring(i, Math.Min(maxChunkSize, text.Length - i)));
    }
    return chunks;
}

static async Task<string?> AskChatGpt(string question)
{
    var apiKey = Environment.GetEnvironmentVariable("OPENAI_API_KEY");
    if (string.IsNullOrEmpty(apiKey))
    {
        return "Error: OPENAI_API_KEY environment variable not set";
    }

    using var httpClient = new HttpClient();
    var request = new HttpRequestMessage(HttpMethod.Post, "https://api.openai.com/v1/chat/completions")
    {
        Content = JsonContent.Create(new
        {
            model = "gpt-4",
            messages = new[]
            {
                new { role = "system", content = "You are a DNS chatbot. Provide concise, plain-text responses under 400 characters. Be direct and helpful." },
                new { role = "user", content = question }
            },
            max_tokens = 80
        })
    };

    request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);

    var response = await httpClient.SendAsync(request);
    if (!response.IsSuccessStatusCode)
    {
        return $"API Error: {response.StatusCode}";
    }

    var json = await response.Content.ReadFromJsonAsync<JsonObject>();
    return json?["choices"]?[0]?["message"]?["content"]?.GetValue<string>()?.Trim();
}