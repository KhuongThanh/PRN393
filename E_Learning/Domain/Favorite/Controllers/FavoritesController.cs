using E_Learning.Domain.Favorite.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace E_Learning.Domain.Favorite.Controllers
{
    [ApiController]
    [Route("api/favorites")]
    [Authorize]
    public class FavoritesController : ControllerBase
    {
        private readonly IFavoriteService _favoriteService;

        public FavoritesController(IFavoriteService favoriteService)
        {
            _favoriteService = favoriteService;
        }

        [HttpPost("{wordId:guid}")]
        public async Task<IActionResult> AddFavorite(Guid wordId)
        {
            var userId = GetUserId();
            await _favoriteService.AddFavoriteAsync(userId, wordId);
            return Ok(new { message = "Added to favorites successfully." });
        }

        [HttpDelete("{wordId:guid}")]
        public async Task<IActionResult> RemoveFavorite(Guid wordId)
        {
            var userId = GetUserId();
            await _favoriteService.RemoveFavoriteAsync(userId, wordId);
            return Ok(new { message = "Removed from favorites successfully." });
        }

        [HttpGet]
        public async Task<IActionResult> GetFavorites()
        {
            var userId = GetUserId();
            var result = await _favoriteService.GetFavoritesAsync(userId);
            return Ok(result);
        }

        private Guid GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                              ?? User.FindFirst("sub")?.Value;

            if (string.IsNullOrWhiteSpace(userIdClaim))
                throw new UnauthorizedAccessException("User id claim not found.");

            return Guid.Parse(userIdClaim);
        }
    }

}
