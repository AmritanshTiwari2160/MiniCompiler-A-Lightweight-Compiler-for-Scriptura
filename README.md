This is a lightweight compiler for Scriptura. Scriptura is a custom language that is highly user-friendly.
### Sample Code Snippet
```scriptura
// Prime check program in Scriptura
input n;  // Read the number

assign flag to 1;
assign i to 2;

while (i less n) {
    if (n mod i equal 0) {
        assign flag to 0;
        assign i to n;  // Break out
    } else {
        assign i + 1 to i;
    }
}

print flag;  // 1 = prime, 0 = not prime
```
### Prerequisites
Before you start, make sure you have the following installed:

- **GNU Bison** (for parsing)
- **Flex** (for lexical analysis)
- **G++** (for compiling)
- **Make** (for building the project)
