import torch
from model import Transformer

def train(model, dataloader, optimizer, epochs=10):
    model.train()
    for epoch in range(epochs):
        for batch in dataloader:
            optimizer.zero_grad()
            output = model(batch)
            loss = output.mean()
            loss.backward()
            optimizer.step()

def evaluate(model, dataloader):
    model.eval()
    with torch.no_grad():
        for batch in dataloader:
            output = model(batch)
    return output

if __name__ == "__main__":
    model = Transformer(d_model=512, num_heads=8)
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-4)
