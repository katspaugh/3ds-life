// The Game of Life
// Rules:
// 1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
// 2. Any live cell with two or three live neighbours lives on to the next generation.
// 3. Any live cell with more than three live neighbours dies, as if by overcrowding.
// 4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

#include <citro2d.h>

#include <string.h>
#include <stdio.h>
#include <stdlib.h>


#define SCREEN_WIDTH  400
#define SCREEN_HEIGHT 240

// The size of each cell
#define CELL_WIDTH  2
#define CELL_HEIGHT 2

// The size of the grid
#define GRID_WIDTH  (SCREEN_WIDTH / CELL_WIDTH)
#define GRID_HEIGHT (SCREEN_HEIGHT / CELL_HEIGHT)

// Init the grid
int grid[GRID_WIDTH][GRID_HEIGHT];

// Init the grid for the next generation
int nextGrid[GRID_WIDTH][GRID_HEIGHT];

//---------------------------------------------------------------------------------
int main(int argc, char* argv[]) {
  //---------------------------------------------------------------------------------
  // Init libs
  gfxInitDefault();
  C3D_Init(C3D_DEFAULT_CMDBUF_SIZE);
  C2D_Init(C2D_DEFAULT_MAX_OBJECTS);
  C2D_Prepare();
  consoleInit(GFX_BOTTOM, NULL);

  // Create screens
  C3D_RenderTarget* top = C2D_CreateScreenTarget(GFX_TOP, GFX_LEFT);

  u32 clrClear = C2D_Color32(0x00, 0x00, 0x00, 0xFF);
  u32 clrRec1 = C2D_Color32(0xFF, 0xD8, 0xB0, 0xFF);

  // Init the grid randomly
  for (int x = 0; x < GRID_WIDTH; x++) {
    for (int y = 0; y < GRID_HEIGHT; y++) {
      grid[x][y] = rand() % 2;
    }
  }

  // Main loop
  while (aptMainLoop())
    {
      hidScanInput();

      // Respond to user input
      u32 kDown = hidKeysDown();
      if (kDown) {
        if (KEY_START) {
          break; // break in order to return to hbmenu
        }
        if (KEY_A) {
          // Init the grid randomly
          for (int x = 0; x < GRID_WIDTH; x++) {
            for (int y = 0; y < GRID_HEIGHT; y++) {
              grid[x][y] = rand() % 2;
              nextGrid[x][y] = grid[x][y];
            }
          }
          continue;
        }
      }

      printf("\x1b[1;1HGame of life");
      printf("\x1b[2;1HCPU:     %6.2f%%\x1b[K", C3D_GetProcessingTime()*6.0f);
      printf("\x1b[3;1HGPU:     %6.2f%%\x1b[K", C3D_GetDrawingTime()*6.0f);
      printf("\x1b[4;1HCmdBuf:  %6.2f%%\x1b[K", C3D_GetCmdBufUsage()*100.0f);
      printf("\x1b[5;1HPress START to exit.");

      // Compute the next generation according to the rules
      // Wrap around the edges
      for (int x = 0; x < GRID_WIDTH; x++) {
        for (int y = 0; y < GRID_HEIGHT; y++) {
          int neighbours = 0;
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              neighbours += grid[(x + i + GRID_WIDTH) % GRID_WIDTH][(y + j + GRID_HEIGHT) % GRID_HEIGHT];
            }
          }
          neighbours -= grid[x][y];
          if ((grid[x][y] == 1) && (neighbours < 2)) {
            nextGrid[x][y] = 0;
          } else if ((grid[x][y] == 1) && (neighbours > 3)) {
            nextGrid[x][y] = 0;
          } else if ((grid[x][y] == 0) && (neighbours == 3)) {
            nextGrid[x][y] = 1;
          } else {
            nextGrid[x][y] = grid[x][y];
          }
        }
      }

      // Copy the next grid to the current grid
      for (int x = 0; x < GRID_WIDTH; x++) {
        for (int y = 0; y < GRID_HEIGHT; y++) {
          grid[x][y] = nextGrid[x][y];
        }
      }

      // Render the scene
      C3D_FrameBegin(C3D_FRAME_SYNCDRAW);
      C2D_TargetClear(top, clrClear);
      C2D_SceneBegin(top);

      // Draw the grid
      for (int x = 0; x < GRID_WIDTH; x++) {
        for (int y = 0; y < GRID_HEIGHT; y++) {
          if (nextGrid[x][y] == 1) {
            C2D_DrawRectSolid(x * CELL_WIDTH, y * CELL_HEIGHT, 0.5f, CELL_WIDTH, CELL_HEIGHT, clrRec1);
          }
        }
      }

      C3D_FrameEnd(0);
    }

  // Deinit libs
  C2D_Fini();
  C3D_Fini();
  gfxExit();
  return 0;
}
