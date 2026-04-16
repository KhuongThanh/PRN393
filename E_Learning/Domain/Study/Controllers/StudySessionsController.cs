using E_Learning.Domain.Study.Dtos;
using E_Learning.Domain.Study.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace E_Learning.Domain.Study.Controllers
{
    [ApiController]
    [Route("api/study-sessions")]
    [Authorize]
    public class StudySessionsController : ControllerBase
    {
        private readonly IStudySessionService _studySessionService;

        public StudySessionsController(IStudySessionService studySessionService)
        {
            _studySessionService = studySessionService;
        }

        [HttpPost("start")]
        public async Task<IActionResult> StartSession([FromBody] StartStudySessionRequest request)
        {
            try
            {
                var userId = GetUserId();
                var result = await _studySessionService.StartSessionAsync(userId, request);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{sessionId:guid}/review")]
        public async Task<IActionResult> ReviewWord(Guid sessionId, [FromBody] ReviewFlashcardRequest request)
        {
            try
            {
                var userId = GetUserId();
                var result = await _studySessionService.ReviewWordAsync(userId, sessionId, request);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{sessionId:guid}/finish")]
        public async Task<IActionResult> FinishSession(Guid sessionId)
        {
            try
            {
                var userId = GetUserId();
                var result = await _studySessionService.FinishSessionAsync(userId, sessionId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("history")]
        public async Task<IActionResult> GetHistory()
        {
            var userId = GetUserId();
            var result = await _studySessionService.GetHistoryAsync(userId);
            return Ok(result);
        }

        [HttpGet("{sessionId:guid}")]
        public async Task<IActionResult> GetSessionDetail(Guid sessionId)
        {
            try
            {
                var userId = GetUserId();
                var result = await _studySessionService.GetSessionDetailAsync(userId, sessionId);
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