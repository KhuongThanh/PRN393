using E_Learning.Domain.Progress.Dtos;
using E_Learning.Domain.Progress.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace E_Learning.Domain.Progress.Controllers
{
    [ApiController]
    [Route("api/progress")]
    [Authorize]
    public class ProgressController : ControllerBase
    {
        private readonly IUserWordProgressService _progressService;

        public ProgressController(IUserWordProgressService progressService)
        {
            _progressService = progressService;
        }

        [HttpGet("summary")]
        public async Task<IActionResult> GetSummary()
        {
            var userId = GetUserId();
            var result = await _progressService.GetSummaryAsync(userId);
            return Ok(result);
        }

        [HttpGet("words/{wordId:guid}")]
        public async Task<IActionResult> GetWordProgress(Guid wordId)
        {
            try
            {
                var userId = GetUserId();
                var result = await _progressService.GetWordProgressAsync(userId, wordId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpPut("words/{wordId:guid}")]
        public async Task<IActionResult> UpdateWordProgress(Guid wordId, [FromBody] UpdateWordProgressRequest request)
        {
            try
            {
                var userId = GetUserId();
                var result = await _progressService.UpdateWordProgressAsync(userId, wordId, request);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpGet("topics/{topicId:guid}")]
        public async Task<IActionResult> GetTopicProgress(Guid topicId)
        {
            try
            {
                var userId = GetUserId();
                var result = await _progressService.GetTopicProgressAsync(userId, topicId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
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
