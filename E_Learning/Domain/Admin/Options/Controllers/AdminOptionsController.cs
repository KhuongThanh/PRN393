using E_Learning.Domain.Admin.Options.Dtos;
using E_Learning.Domain.Admin.Options.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace E_Learning.Domain.Admin.Options.Controllers
{
    [ApiController]
    [Route("api/admin")]
    [Authorize(Roles = "Admin")]
    public class AdminOptionsController : ControllerBase
    {
        private readonly IAdminOptionService _optionService;

        public AdminOptionsController(IAdminOptionService optionService)
        {
            _optionService = optionService;
        }

        [HttpGet("questions/{questionId:guid}/options")]
        public async Task<IActionResult> GetByQuestion(Guid questionId)
        {
            try
            {
                var result = await _optionService.GetByQuestionAsync(questionId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpGet("options/{optionId:guid}")]
        public async Task<IActionResult> GetById(Guid optionId)
        {
            try
            {
                var result = await _optionService.GetByIdAsync(optionId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpPost("questions/{questionId:guid}/options")]
        public async Task<IActionResult> Create(Guid questionId, [FromBody] CreateOptionRequest request)
        {
            try
            {
                var result = await _optionService.CreateAsync(questionId, request);
                return CreatedAtAction(nameof(GetById), new { optionId = result.OptionId }, result);
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

        [HttpPut("options/{optionId:guid}")]
        public async Task<IActionResult> Update(Guid optionId, [FromBody] UpdateOptionRequest request)
        {
            try
            {
                var result = await _optionService.UpdateAsync(optionId, request);
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

        [HttpDelete("options/{optionId:guid}")]
        public async Task<IActionResult> Delete(Guid optionId)
        {
            try
            {
                await _optionService.DeleteAsync(optionId);
                return Ok(new { message = "Option deleted successfully." });
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
    }
}
